1. **本轮唯一假设：将学习率衰减阶段从训练预算的后50%延长到后80%，让模型更早进入较小学习率阶段，可以降低最终 val_bpb。**

   第3轮继续减小批量、第4轮降低嵌入学习率，都未获得更低的验证分数。第4轮与第2轮的训练量接近，但分数差异很小，尚不能据此判断嵌入学习率的稳定优劣。本轮基于恢复后的第2轮版本，测试学习率衰减时机。

   将 `WARMDOWN_RATIO` 从 `0.5` 改为 `0.8` 后，学习率从计时训练进度20%处开始线性下降，并在预算结束时降至零。预期收益是减少中后期更新幅度，使有限预算内的训练更充分地收敛。风险是过早降低学习率，削弱前中期的学习速度，导致最终欠拟合。

2. 补丁（基于本轮权威 `next_train.py`，目标文件为 `train.py`）：

```diff
diff --git a/train.py b/train.py
--- a/train.py
+++ b/train.py
@@ -511,7 +511,7 @@
 WEIGHT_DECAY = 0.2      # cautious weight decay for Muon
 ADAM_BETAS = (0.8, 0.95) # Adam beta1, beta2
 WARMUP_RATIO = 0.0      # fraction of time budget for LR warmup
-WARMDOWN_RATIO = 0.5    # fraction of time budget for LR warmdown
+WARMDOWN_RATIO = 0.8    # fraction of time budget for LR warmdown
 FINAL_LR_FRAC = 0.0     # final LR as fraction of initial
 
 # Model size
```

3. **根据真实反馈判断：**

   - 运行成功、退出码0且最终官方 `val_bpb` 有限后，只有 **`val_bpb < 1.043261`** 才保留；否则最终保留版本仍为第2轮版本。
   - 检查日志中的 `lrm` 是否在计时进度20%之后开始下降。这个改动只调整学习率调度比例，不改变300秒预算或计时逻辑。
   - 对照第2轮相近计时进度下的训练损失，观察更早衰减是否改善后期收敛，或造成训练损失持续落后。最终验证分数是决定依据。
   - 查看 `num_steps`、`total_tokens_M`、`training_seconds`，辅助判断实际训练量差异；同时记录 `peak_vram_mb` 和 `total_seconds`。单次分数变化只作为观察结果，不声明统计显著性。

我未运行代码或验证补丁，等待最后一轮真实反馈。
