"""Manual platform check; never starts training or reads benchmark data.

Extract the adapter with AST so importing train.py cannot start training.
Run on the remote project interpreter with CUDA_VISIBLE_DEVICES=0.
"""
import ast
import sys
from pathlib import Path

import torch
import torch.nn.functional as F


def load_adapter():
    source = (Path(sys.argv[1]) if len(sys.argv) > 1
              else Path(__file__).resolve().parents[1] / "train.py")
    tree = ast.parse(source.read_text(encoding="utf-8"))
    functions = [node for node in tree.body
                 if isinstance(node, ast.FunctionDef) and node.name == "platform_attention"]
    if len(functions) != 1:
        raise RuntimeError("Expected exactly one platform_attention function in train.py")
    namespace = {"torch": torch, "F": F}
    exec(compile(ast.Module(body=functions, type_ignores=[]), str(source), "exec"), namespace)
    return namespace["platform_attention"]


def reference_attention(q, k, v, left):
    # Independent row-by-row definition; compute the reference in float32.
    repeats = q.size(2) // k.size(2)
    q = q.float()
    k = k.float().repeat_interleave(repeats, dim=2)
    v = v.float().repeat_interleave(repeats, dim=2)
    rows = []
    for row in range(q.size(1)):
        start = 0 if left == -1 else max(0, row - left)
        keys = k[:, start:row + 1]
        values = v[:, start:row + 1]
        scores = torch.einsum("bhd,bshd->bhs", q[:, row], keys) / q.size(-1) ** 0.5
        rows.append(torch.einsum("bhs,bshd->bhd", scores.softmax(dim=-1), values))
    return torch.stack(rows, dim=1)


def check_numerics(attention):
    for dtype in (torch.float32, torch.bfloat16):
        for kv_heads in (4, 2):
            for left in (-1, 0, 3, 17):
                inputs = [
                    torch.randn(2, 17, heads, 32, device="cuda", dtype=dtype,
                                requires_grad=True)
                    for heads in (4, kv_heads, kv_heads)
                ]
                refs = [x.detach().clone().requires_grad_(True) for x in inputs]
                actual = attention(*inputs, (left, 0))
                expected = reference_attention(*refs, left)
                upstream = torch.randn_like(actual)
                actual_grads = torch.autograd.grad((actual * upstream).sum(), inputs)
                expected_grads = torch.autograd.grad((expected * upstream.float()).sum(), refs)
                # Numerical tolerances only, never benchmark score thresholds.
                atol, rtol = (5e-5, 1e-4) if dtype == torch.float32 else (3e-2, 3e-2)
                torch.testing.assert_close(actual.float(), expected, atol=atol, rtol=rtol)
                for actual_grad, expected_grad in zip(actual_grads, expected_grads):
                    torch.testing.assert_close(actual_grad.float(), expected_grad.float(),
                                               atol=atol, rtol=rtol)
                print(f"PASS output/gradients: {dtype}, kv_heads={kv_heads}, left={left}",
                      flush=True)


def check_compilation(attention):
    compiled = torch.compile(attention, dynamic=False, fullgraph=True)
    for left in (2048, 1024):
        inputs = [torch.randn(1, 2048, 4, 128, device="cuda", dtype=torch.bfloat16,
                              requires_grad=True) for _ in range(3)]
        eager = attention(*inputs, (left, 0))
        result = compiled(*inputs, (left, 0))
        torch.testing.assert_close(result, eager, atol=3e-2, rtol=3e-2)
        result.float().square().mean().backward()
        assert torch.isfinite(result).all().item()
        assert all(x.grad is not None and torch.isfinite(x.grad).all().item()
                   for x in inputs)
        torch.cuda.synchronize()
        print(f"PASS compiled forward/backward: sequence=2048, left={left}", flush=True)


if __name__ == "__main__":
    torch.manual_seed(42)
    print("GPU:", torch.cuda.get_device_name(0), flush=True)
    print("PyTorch:", torch.__version__, flush=True)
    adapter = load_adapter()
    check_numerics(adapter)
    check_compilation(adapter)
    print("PLATFORM_ATTENTION_CHECK_PASSED", flush=True)
