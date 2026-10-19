# GPT B2 运行与保留记录

日期2026-10-19（Asia/Shanghai）。用户贴回真实运行与收尾输出；随后助手只取回证据，没有代跑训练或收尾。

| 项目 | 结果 |
|---|---|
| exit_code | 0 |
| val_bpb | 1.043261 |
| training_seconds | 300.1 |
| total_seconds | 335.3 |
| peak_vram_mb | 11702.0 |
| total_tokens_M | 188.7 |
| num_steps | 1440 |
| num_params_M | 50.3 |
| depth | 8 |
| 梯度累积次数 | 2 |
| 人工规则复核 | clean（未观察到违规，不保证后台行为） |
| 决定 | keep |
| 新最佳commit | 659575bc6c5e95f98bfd4c280881c726d801c721 |

相对B1的1.082689降低0.039428；总训练token从196.6M减少到188.7M，更新次数从375增至1440。观察到较低分数，不证明唯一机制、普适优势或统计显著。
relative共同基线1.164027的改善为0.120766（约10.37%）。mfu使用H100分母，不作为5090真实利用率。
完整原始证据保存在remote_evidence/；feedback_to_gpt/只放要上传的两个附件和要粘贴的提示词。
