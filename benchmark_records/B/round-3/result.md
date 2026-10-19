# GPT B3 运行与回退记录

日期2026-10-19（Asia/Shanghai）。用户提供真实运行与人工收尾输出；助手随后取回原始证据，未代跑训练或收尾。

| 项目 | 结果 |
|---|---|
| exit_code | 0 |
| val_bpb | 1.048139 |
| training_seconds | 300.0 |
| total_seconds | 334.5 |
| peak_vram_mb | 11550.0 |
| total_tokens_M | 183.7 |
| num_steps | 2803 |
| num_params_M | 50.3 |
| depth | 8 |
| 梯度累积次数 | 1 |
| 人工规则复核 | clean |
| 决定 | revert |
| 当前最佳val_bpb | 1.043261 |
| 回退后commit | 659575bc6c5e95f98bfd4c280881c726d801c721 |

候选比此前最佳高0.004878，按规则回退；成功运行不等于成功改善。本轮机会已消耗。回退后的next_train.py与B2保留版本SHA256一致，TOTAL_BATCH_SIZE恢复为2**17。
单次结果不证明更小批量普遍无效，不估计统计显著性。未添加助手优化建议到模型反馈。
