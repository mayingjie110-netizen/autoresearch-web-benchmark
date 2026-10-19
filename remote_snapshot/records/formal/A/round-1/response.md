### 1. 本轮唯一假设、预期收益与风险

* **唯一假设**：将注意力窗口模式 `WINDOW_PATTERN` 从 `"SSSL"` 改为全长因果窗口 `"L"`，消除 `platform_attention` 中短窗口（`S`）分支逐层构造 `2048×2048` 布尔 `attn_mask` 所导致的 SDPA 慢速回退路径，使全部 8 层均走 `is_causal=True` 的原生快速因果注意力内核，同时恢复前 6 层的完整上下文感受野。
* **预期收益**：
1. **训练吞吐提升**：在 `platform_attention` 实现中，当 `left < seq_len - 1`（即 `S` 层，窗口 1024）时，代码会生成二维布尔掩码 `allowed` 并传入 `F.scaled_dot_product_attention(..., attn_mask=allowed)`，无法使用无显式掩码的 `is_causal=True` 快速路径；改为 `"L"` 后所有层均满足 `left >= seq_len - 1`，直接调用 `is_causal=True` 快速路径，在 300 秒固定预算内可完成更多优化步数与训练 token 数。
2. **长程建模能力提升**：前 6 层注意力上下文从半长（1024）扩展为全长（2048），在相同架构参数量下增强跨位置信息交互。


* **风险**：
1. 若全长因果注意力在 PyTorch SDPA 下的真实算力开销高于掩码调度的节省，单步耗时 `dt` 可能不降反升。
2. 显存占用可能因消除了布尔掩码物化而持平或略降，也可能因后端内核切换产生小幅波动（当前峰值显存 11710.0 MiB，距 32 GB 上限裕量充足）。



### 2. Git Unified Diff 补丁

```diff
diff --git a/train.py b/train.py
--- a/train.py
+++ b/train.py
@@ -450,7 +450,7 @@
 # Model architecture
 ASPECT_RATIO = 64       # model_dim = depth * ASPECT_RATIO
 HEAD_DIM = 128          # target head dimension for attention
-WINDOW_PATTERN = "SSSL" # sliding window pattern: L=full, S=half context
+WINDOW_PATTERN = "L"    # sliding window pattern: L=full, S=half context
 
 # Optimization
 TOTAL_BATCH_SIZE = 2**19 # ~524K tokens per optimizer step

```

### 3. 基于真实反馈的验证标准

收到本轮运行日志后，通过以下指标对比共同基线（`val_bpb=1.164027`、`num_steps=199`、`total_tokens_M=104.3`、`peak_vram_mb=11710.0`）来判断假设是否成立：

1. **吞吐与步数（`num_steps` / `total_tokens_M` / 单步 `dt`）**：观察 300 秒预算内完成的步数是否高于 199 步（对应 `total_tokens_M` 是否高于 104.3M），以验证去除显式布尔 `attn_mask`、统一走 `is_causal=True` 是否在 RTX 5090 + PyTorch 2.9.1 SDPA 上带来实际加速。
2. **启动与编译耗时（`total_seconds - training_seconds`）**：观察统一窗口配置是否减少了 `torch.compile` 对不同注意力分支的编译开销。
3. **显存变化（`peak_vram_mb`）**：确认不构造 `allowed` 掩码及后端内核切换对峰值显存的实际影响，为后续调整批次或模型规模提供依据。
4. **核心评价指标（`val_bpb`）**：检验 `val_bpb` 是否严格低于 `1.164027`，以决定本轮改动保留或回退。
