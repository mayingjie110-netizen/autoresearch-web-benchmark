### 1. 本轮唯一假设、预期收益与风险

* **唯一假设**：基于前四轮真实反馈——总批次从 `2**19` 降至 `2**17` 使总步数从 374 步增至 1440 步并取得当前最佳 `val_bpb = 1.041990`，而第 4 轮进一步降至 `2**16`（2804 步）回退至 `1.048104`，且日志显示在较小批次与默认高初始学习率下，训练进度 30%–50% 区间（保持 `lrm = 1.00` 恒定期间）损失下降明显趋缓，直至 50% 进度启动学习率线性冷却（warmdown）后才重新快速下降——本轮在 `TOTAL_BATCH_SIZE = 2**17` 基础上，将学习率线性冷却比例 `WARMDOWN_RATIO` 从 `0.5` 提高至 `0.7`（即前 30% 训练时间保持峰值学习率 `lrm = 1.00`，后 70% 训练时间线性衰减至 0），以匹配 `2**17` 批次下的梯度噪声水平与 1440 步训练尺度，进一步降低 `val_bpb`。
* **预期收益**：
1. **消除中段恒定高学习率平台期**：在 `TOTAL_BATCH_SIZE = 2**17`（约 1440 步）下，前 30% 进度已对应约 432 步峰值学习率训练（完整覆盖前 300 步 Muon 动量爬坡期，且峰值学习率步数已超过第 1 轮的 187 步和第 2 轮的 367 步）；从 30% 进度（约第 432 步）起提前进入线性衰减，可避免模型在 30%–50% 区间因学习率相对 131K 批次偏高而发生震荡停滞。
2. **延长冷却精细收敛阶段且零吞吐损耗**：线性冷却步数从约 720 步扩展至约 1008 步，衰减斜率更平缓，同时不改变计算图、显存占用（保持 11702.0 MiB）与单步耗时（保持 `dt≈210ms`、约 1440 步）。


* **风险**：
1. 若前 30% 之后提前衰减使中段（30%–60% 进度）有效学习率偏低，可能略微放缓对新数据分布特征的探索速度。
2. 若 `WARMDOWN_RATIO = 0.5` 已接近该步数下的最优冷却起点，改为 `0.7` 可能导致最终 `val_bpb` 改善幅度有限或略逊于 `1.041990`。



### 2. Git Unified Diff 补丁

```diff
diff --git a/train.py b/train.py
--- a/train.py
+++ b/train.py
@@ -461,7 +461,7 @@
 WEIGHT_DECAY = 0.2      # cautious weight decay for Muon
 ADAM_BETAS = (0.8, 0.95) # Adam beta1, beta2
 WARMUP_RATIO = 0.0      # fraction of time budget for LR warmup
-WARMDOWN_RATIO = 0.5    # fraction of time budget for LR warmdown
+WARMDOWN_RATIO = 0.7    # fraction of time budget for LR warmdown
 FINAL_LR_FRAC = 0.0     # final LR as fraction of initial
 
 # Model size

```

### 3. 基于真实反馈的验证标准

收到第 5 轮运行反馈后，对照第 3 轮当前最佳结果（`val_bpb=1.041990`、`num_steps=1440`、`total_tokens_M=188.7`、单步 `dt≈210ms`、训末 `loss=2.932743`）重点观察：

1. **学习率调度触发位置（`lrm` 与 `pct_done`）**：确认日志中 `lrm` 在 `pct_done ≈ 30.0%`（约第 430 步）开始从 `1.00` 线性递减，且总步数 `num_steps` 与 `total_tokens_M` 与第 3 轮（1440 步、188.7M）基本一致。
2. **中段与末段损失轨迹（`loss`）**：对比 30%–50% 训练进度区间的 `debiased_smooth_loss` 是否比 `WARMDOWN_RATIO = 0.5` 时下降更顺畅，以及训末平滑损失是否低于第 3 轮的 `2.932743`。
3. **核心评价指标（`val_bpb`）**：检验最终 `val_bpb` 是否严格低于当前最佳值 `1.041990`，以判定假设是否成立并决定最终保留版本。
