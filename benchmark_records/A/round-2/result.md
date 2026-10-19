# A2 真实运行结果

用户于2026-10-19（Asia/Shanghai）反馈，完整远程证据已取回remote_evidence/；本助手未代跑训练。

```
Exit code: 0
val_bpb:          1.070800
training_seconds: 300.2
total_seconds:    337.8
peak_vram_mb:     11702.0
mfu_percent:      17.68
total_tokens_M:   192.4
num_steps:        734
num_params_M:     50.3
depth:            8
```

窗口L，梯度累积4，最后一步dt415ms、tok/sec630997。原始完整日志见remote_evidence/run.log。
相对A1的1.083021，观察到下降0.012221，约1.13%；相对共同基线1.164027，累计下降0.093227，约8.01%。更新次数374->734，报告总tokens196.1M->192.4M（包含未计时预热，批量变化也改变这部分token数），不能把总tokens差额全部归因为优化器开销。
取回证据已包含review.txt，确认用户已收尾：manual_rule_review=clean、valid=yes、decision=keep，当前最佳1.070800。无需重复执行收尾。mfu仍是H100分母，不按5090真实利用率解释；不声称统计显著性或唯一机制得到证明。
