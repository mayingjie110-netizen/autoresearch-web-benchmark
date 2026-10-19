# GPT B1：真实结果

2026-10-19（Asia/Shanghai）用户贴回结果；本助手从远程正式B1目录取回原始文件，保存至remote_evidence/，未代跑训练。

```
Exit code: 0
val_bpb:          1.082689
training_seconds: 300.7
total_seconds:    342.5
peak_vram_mb:     11702.0
mfu_percent:      17.81
total_tokens_M:   196.6
num_steps:        375
num_params_M:     50.3
depth:            8
```

配置window_pattern=L，梯度累积8；相对共同单次基线1.164027，绝对降低0.081338，约6.99%。按严格更低规则应保留，前提为人工未观察到违规。尚未执行finish_round.sh，不将建议保留写成已经完成。
该结果不证明具体SDPA后端，也不作与另一产品的比较。用户已指定本分支只负责GPT。
