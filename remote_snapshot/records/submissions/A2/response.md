1. 本轮唯一假设、预期收益与风险

* **唯一假设**：将总批次大小 `TOTAL_BATCH_SIZE` 从 `2**19`（524,288 tokens，梯度累积 8 步）减半至 `2**18`（262,144 tokens，梯度累积 4 步），在不显著损失令牌吞吐率的前提下，使 300 秒预算内的优化器参数更新步数翻倍，从而提升训练收敛效率并降低 `val_bpb`。
* **预期收益**：
1. **增加有效参数更新步数**：第 1 轮在 300 秒内处理了 196.1M tokens，但因 `TOTAL_BATCH_SIZE = 2**19` 过大，仅执行了 374 次优化器更新；减半至 `2**18` 后，单次更新仍包含 128 条长度为 2048 的序列（262K tokens），在保持梯度估计稳定的同时可使总更新步数接近翻倍。
2. **改善按步数调度的优化器动态**：`get_muon_momentum(step)` 固定在前 300 步内将动量从 0.85 线性推升至 0.95。第 1 轮总步数仅 374 步，导致约 80% 的训练过程处于动量爬坡期；步数翻倍后，模型将在更大比例的训练时间内以完整动量（0.95）和更匹配的 AdamW/Muon 指数滑动平均窗口进行优化（更接近原仓库在 H100 上调参时的总步数区间）。


* **风险**：
1. 优化器更新频率翻倍会使 `optimizer.step()` 调用次数增加一倍，可能略微增加每百万 token 的均摊耗时，导致 `total_tokens_M` 相比第 1 轮（196.1M）出现轻微下降。
2. 单步批次减半会略微增大单步梯度方差，若当前默认学习率（`MATRIX_LR = 0.04`、`EMBEDDING_LR = 0.6`）对 262K 批次偏激进，后期收敛平稳性可能受影响。



### 2. Git Unified Diff 补丁

```diff
diff --git a/train.py b/train.py
--- a/train.py
+++ b/train.py
@@ -453,7 +453,7 @@
 WINDOW_PATTERN = "L"    # sliding window pattern: L=full, S=half context
 
 # Optimization
-TOTAL_BATCH_SIZE = 2**19 # ~524K tokens per optimizer step
+TOTAL_BATCH_SIZE = 2**18 # ~262K tokens per optimizer step
 EMBEDDING_LR = 0.6      # learning rate for token embeddings (Adam)
 UNEMBEDDING_LR = 0.004  # learning rate for lm_head (Adam)
 MATRIX_LR = 0.04        # learning rate for matrix parameters (Muon)

```

### 3. 基于真实反馈的验证标准

收到第 2 轮运行反馈后，对照第 1 轮最佳结果（`val_bpb=1.083021`、`num_steps=374`、`total_tokens_M=196.1`、单步 `dt≈826ms`）重点检查以下指标：

1. **步数与单步耗时（`num_steps` / `dt`）**：确认 `Gradient accumulation steps` 变为 4 后，单步 `dt` 是否接近减半，以及 300 秒预算内完成的 `num_steps` 是否接近第 1 轮（374 步）的两倍。
2. **总训练吞吐（`total_tokens_M` / `tok/sec`）**：对比 `total_tokens_M` 与第 1 轮的 196.1M，评估更频繁调用 `optimizer.step()` 带来的额外开销占比。
3. **训练损失下降轨迹（`loss`）**：观察日志中相同训练进度百分比（`pct_done`）及冷却阶段的 `debiased_smooth_loss` 是否低于第 1 轮同期水平，且无异常震荡。
4. **核心评价指标（`val_bpb`）**：检查最终 `val_bpb` 是否严格低于当前最佳值 `1.083021`，以判定假设是否成立并决定保留或回退。
