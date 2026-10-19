# A3 真实结果与收尾

用户于2026-10-19（Asia/Shanghai）反馈完整汇总及收尾输出，远程完整证据另已取回remote_evidence/；未代用户执行训练。

```
Exit code: 0
val_bpb:          1.041990
training_seconds: 300.1
total_seconds:    335.7
peak_vram_mb:     11702.0
mfu_percent:      17.47
total_tokens_M:   188.7
num_steps:        1440
num_params_M:     50.3
depth:            8
```

窗口L，梯度累积2；末步dt210ms、tok/sec623464、loss2.932743。
已人工收尾：clean、valid=yes、keep；最佳1.041990，保留commit b974902aeb47673f6827ba2ac4a89226a21af317。
对比A2的1.070800，观察下降0.028810，约2.69%；共同单次基线1.164027到当前累计观察下降0.122037，约10.48%。
模型预期约1450步，本次1440步。结果支持本次减小总批量后获得更低指标，但没有隔离更新次数、动量调度、噪声等机制，也没有重复估计显著性。
token总量包含未计时预热；mfu是H100分母，不能按5090真实利用率解释。
