### 1. 本轮唯一假设、预期收益与风险

* **唯一假设**：基于前两轮连续减半总批次的真实反馈——`TOTAL_BATCH_SIZE` 从 `2**19` 降至 `2**18` 使 `val_bpb` 改善 `0.012221`（`1.083021 → 1.070800`），从 `2**18` 降至 `2**17` 使 `val_bpb` 进一步大幅改善 `0.028810`（`1.070800 → 1.041990`，步数增至 1440 步，训末平滑损失降至 `2.932743`），边际收益呈扩大趋势——本轮继续将 `TOTAL_BATCH_SIZE` 从 `2**17`（131,072 tokens，梯度累积 2 步）减半至 `2**16`（65,536 tokens，梯度累积 1 步，即单卡微批次本身），使每次前向/反向传播后立即执行参数更新，在 300 秒预算内将更新步数推升至约 2800 步，以检验无梯度累积的高频更新能否进一步降低 `val_bpb`。
* **预期收益**：
1. **参数更新频率再翻倍且消除梯度累积冗余**：`DEVICE_BATCH_SIZE * MAX_SEQ_LEN = 32 * 2048 = 2**16`，设 `TOTAL_BATCH_SIZE = 2**16` 后 `grad_accum_steps = 1`，每次反向传播后直接更新权重，总优化步数预计从 1440 步增至约 2800 步。
2. **优化器更快进入稳态**：`get_muon_momentum(step)` 的 300 步动量爬坡期占比将从第 3 轮的约 21%（300/1440）进一步压缩至约 11%，使约 89% 的训练过程处于完整动量稳态。


* **风险**：
1. 批次降至 `65,536` tokens（32 条 2048 序列）而未下调学习率（`MATRIX_LR = 0.04`、`EMBEDDING_LR = 0.6`）时，单步梯度噪声进一步上升；若 `2**17` 已达到当前学习率下的临界批次边界，`2**16` 可能因梯度方差过大导致后期收敛受阻。
2. `optimizer.step()` 调用次数增至约 2800 次，总训练吞吐 `total_tokens_M` 相比第 3 轮（188.7M）将继续小幅下降（预计减少约 3M–4M tokens）。



### 2. Git Unified Diff 补丁

```diff
diff --git a/train.py b/train.py
--- a/train.py
+++ b/train.py
@@ -453,7 +453,7 @@
 WINDOW_PATTERN = "L"    # sliding window pattern: L=full, S=half context
 
 # Optimization
-TOTAL_BATCH_SIZE = 2**17 # ~131K tokens per optimizer step
+TOTAL_BATCH_SIZE = 2**16 # ~65K tokens per optimizer step
 EMBEDDING_LR = 0.6      # learning rate for token embeddings (Adam)
 UNEMBEDDING_LR = 0.004  # learning rate for lm_head (Adam)
 MATRIX_LR = 0.04        # learning rate for matrix parameters (Muon)

```

### 3. 基于真实反馈的验证标准

收到第 4 轮运行反馈后，对照第 3 轮最佳结果（`val_bpb=1.041990`、`num_steps=1440`、`total_tokens_M=188.7`、单步 `dt≈210ms`、训末 `loss=2.932743`）重点观察：

1. **步数与单步耗时（`num_steps` / `dt`）**：确认 `Gradient accumulation steps: 1` 下单步 `dt` 是否降至约 107ms 左右，以及 300 秒内完成的 `num_steps` 是否达到约 2800 步。
2. **吞吐损耗（`total_tokens_M` / `tok/sec`）**：观察每微步均执行 `optimizer.step()` 后，`tok/sec` 相比 623,464 的下降比例及 `total_tokens_M` 相比 188.7M 的实际减少量。
3. **训练损失收敛稳定性（`loss`）**：检查在 65K 批次与默认学习率下，`debiased_smooth_loss` 是否出现明显震荡，以及训末损失能否继续低于 `2.932743`。
4. **核心评价指标（`val_bpb`）**：检验 `val_bpb` 是否严格低于当前最佳值 `1.041990`，以此确定最优批次大小落点并决定本轮保留或回退。
