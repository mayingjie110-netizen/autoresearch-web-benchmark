1. **本轮唯一假设：将嵌入参数的基础学习率从 `0.6` 降到 `0.2`，可以减少过大的嵌入更新，改善最终 val_bpb。**

   第3轮增加更新次数后，val_bpb从此前最佳1.043261变为1.048139，没有支持继续减小批量。本轮基于已恢复的第2轮版本，保留总批量 `2**17`、设备批量32和梯度累积2，转而测试嵌入学习率。

   当前 `EMBEDDING_LR` 同时控制输入 token 嵌入和各层 value embedding；经过宽度缩放后，实际初始学习率还会乘以约1.224745。降低这一学习率，可能让这些参数的更新更稳定，并改善与 Transformer 矩阵参数的协同学习。风险是嵌入学习变慢，在五分钟预算内欠拟合。这个假设尚未由现有结果直接证实。

2. 补丁（基于恢复后的第2轮保留版本，目标文件为 `train.py`）：

```diff
diff --git a/train.py b/train.py
--- a/train.py
+++ b/train.py
@@ -503,7 +503,7 @@
 
 # Optimization
 TOTAL_BATCH_SIZE = 2**17 # ~131K tokens per optimizer step
-EMBEDDING_LR = 0.6      # learning rate for token embeddings (Adam)
+EMBEDDING_LR = 0.2      # learning rate for token embeddings (Adam)
 UNEMBEDDING_LR = 0.004  # learning rate for lm_head (Adam)
 MATRIX_LR = 0.04        # learning rate for matrix parameters (Muon)
 SCALAR_LR = 0.5         # learning rate for per-layer scalars (Adam)
```

3. **根据真实反馈判断：**

   - 在补丁有效、退出码0、最终官方 `val_bpb` 有限的前提下，只有 **`val_bpb < 1.043261`** 才保留。
   - 对照第2轮在相近计时进度下的训练损失，观察降低嵌入学习率是否改善中后期收敛，或导致持续落后。训练损失只作为辅助证据，最终判断仍以官方验证分数为准。
   - 查看 `num_steps`、`total_tokens_M` 和 `training_seconds`，确认实际训练量是否接近第2轮的1440步、188.7M tokens，以辅助解释分数变化。
   - 记录 `peak_vram_mb` 和 `total_seconds`。本轮同时调整两类嵌入的共同学习率，结果无法单独归因于输入嵌入或 value embedding；单次差异也不能证明统计显著性。

我未运行代码或验证补丁，等待本轮真实反馈。
