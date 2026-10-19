### 1. 本轮唯一假设、预期收益与风险

* **唯一假设**：基于第 2 轮真实反馈（`TOTAL_BATCH_SIZE` 从 `2**19` 减半至 `2**18` 后，`num_steps` 从 374 增至 734，`total_tokens_M` 仅从 196.1M 微降至 192.4M，训末平滑损失从 3.039976 降至 2.990010，`val_bpb` 从 `1.083021` 显著降至 `1.070800`），本轮继续将 `TOTAL_BATCH_SIZE` 从 `2**18`（262,144 tokens，梯度累积 4 步）减半至 `2**17`（131,072 tokens，梯度累积 2 步），在约 190M tokens 的 300 秒训练预算下将优化器更新步数进一步提升至约 1450 步，进一步提高数据利用效率并降低 `val_bpb`。
* **预期收益**：
1. **更新步数再次翻倍**：第 2 轮单步耗时 `dt≈415ms`（对比第 1 轮 `826ms`），说明单次 `optimizer.step()` 开销仅约 2ms；将梯度累积步数从 4 降至 2 后，预计总吞吐率损耗仍极小，而参数更新次数可从 734 步增至约 1450 步。
2. **动量爬坡占比进一步缩短**：`get_muon_momentum(step)` 的前 300 步爬坡期占总训练步数的比例将从第 2 轮的约 41%（300/734）降至约 21%，使模型在约 80% 的训练步数中保持完整 Muon 动量（0.95）。


* **风险**：
1. 当单步批次降至 131K tokens（64 条 2048 序列）且未同步下调学习率（`MATRIX_LR = 0.04`、`EMBEDDING_LR = 0.6`）时，单步梯度方差增大，若已越过当前学习率下的临界批次大小（critical batch size），可能导致优化轨迹震荡甚至劣于 `2**18`。
2. `optimizer.step()` 调用次数增至约 1450 次，总训练吞吐 `total_tokens_M` 会比第 2 轮（192.4M）略微减少。



### 2. Git Unified Diff 补丁

```diff
diff --git a/train.py b/train.py
--- a/train.py
+++ b/train.py
@@ -453,7 +453,7 @@
 WINDOW_PATTERN = "L"    # sliding window pattern: L=full, S=half context
 
 # Optimization
-TOTAL_BATCH_SIZE = 2**18 # ~262K tokens per optimizer step
+TOTAL_BATCH_SIZE = 2**17 # ~131K tokens per optimizer step
 EMBEDDING_LR = 0.6      # learning rate for token embeddings (Adam)
 UNEMBEDDING_LR = 0.004  # learning rate for lm_head (Adam)
 MATRIX_LR = 0.04        # learning rate for matrix parameters (Muon)

```

### 3. 基于真实反馈的验证标准

收到第 3 轮运行反馈后，对照第 2 轮最佳结果（`val_bpb=1.070800`、`num_steps=734`、`total_tokens_M=192.4`、单步 `dt≈415ms`、训末 `loss=2.990010`）重点观察：

1. **步数与单步耗时（`num_steps` / `dt`）**：验证 `Gradient accumulation steps: 2` 下单步 `dt` 是否降至约 210ms 左右，以及 `num_steps` 是否翻倍至 1400 步以上。
2. **吞吐损耗（`total_tokens_M` / `tok/sec`）**：观察 `total_tokens_M` 相比 192.4M 的下降幅度，确认更频繁的 `optimizer.step()` 是否带来明显的额外时间开销。
3. **收敛稳定性与训末损失（`loss`）**：检查日志中 `debiased_smooth_loss` 在固定学习率下的下降是否依然平稳，以及训末损失是否进一步低于第 2 轮的 `2.990010`。
4. **核心评价指标（`val_bpb`）**：检验 `val_bpb` 是否严格低于当前最佳值 `1.070800`，以此判断在默认学习率下 `2**17` 批次是否优于 `2**18` 并决定保留或回退。
