# A1 原始结果归档与协议判定

2026-10-19（Asia/Shanghai）用户反馈，随后从远程取回完整证据到 remote_evidence/。

```
Exit code: 0
val_bpb:          1.083021
training_seconds: 300.0
total_seconds:    366.3
peak_vram_mb:     11702.0
mfu_percent:      17.79
total_tokens_M:   196.1
num_steps:        374
num_params_M:     50.3
depth:            8
```

实际配置 window_pattern=L，梯度累积8。原始完整run.log等见remote_evidence/，不以本摘要替代。
相对单次共同基线1.164027，观察到绝对降低0.081006，约6.96%；更新步数199->374。
按已冻结严格更低规则，应保留A1，前提为用户未观察到工具或其他违规。修改窗口属于允许架构调整，不是平台准备时须保持窗口不变的限制。
当前尚未代用户执行finish_round.sh，保留决定待人工收尾。未运行B1，不给B方披露本结果。
没有基线重复，不估计显著性；加速不单独证明具体SDPA后端或掩码构建是唯一原因。
