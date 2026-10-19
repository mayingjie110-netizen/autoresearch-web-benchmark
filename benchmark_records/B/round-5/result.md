# GPT B5 运行与保留记录

归档日期：2026-10-19（Asia/Shanghai）。用户手动运行及收尾后提供终端输出，助手随后取回B5原始远程证据并核验。用户同时贴出了另一产品输出，B5归档及反馈仅采用明确标记B方的日志和review.txt；未将另一产品结果混入模型反馈。

正式机会5/5。唯一候选改动WARMDOWN_RATIO 0.5→0.8，起点commit为659575bc6c5e95f98bfd4c280881c726d801c721。提交补丁与实际执行的model.patch SHA256一致，未修补原模型输出。

| 项目 | 结果 |
|---|---|
| exit_code | 0 |
| val_bpb | 1.042717 |
| training_seconds | 300.1 |
| total_seconds | 335.2 |
| peak_vram_mb | 11702.0 |
| mfu_percent（日志值） | 17.45 |
| total_tokens_M | 188.5 |
| num_steps | 1438 |
| num_params_M | 50.3 |
| depth | 8 |
| 梯度累积次数 | 2 |
| 人工规则复核 | clean（用户报告，不能证明不可见行为） |
| valid | yes |
| decision | keep |
| best_val_bpb | 1.042717 |
| next_commit | 0a3d31f77aa98549ece299e1541c9710565b3bce |

本轮比此前最佳1.043261低0.000544，按冻结规则保留；不能将该小差异解释为超出未知运行波动。五轮正式机会已全部消耗，不启动第6轮。

运行UTC起止为2026-10-19T05:11:41Z至05:17:22Z，来自原始start_utc.txt/end_utc.txt；不等同于网页发送时间。运行命令、GPU前后状态、代码状态、固定随机种子42所在源文件、候选/起点/最终代码、补丁应用与原始日志在remote_evidence/。环境、数据和预算按冻结准备包，本次未另行运行环境探测。mfu日志口径不能当作5090实际硬件利用率。

remote_evidence/status.txt保留运行阶段状态；最终收尾以review.txt及远程HEAD核验为准。未改写原始证据。

- run.log及上传版run_log.txt SHA256：8b0a8af66ade049f0d015dfc5ff4374ae710aa1166d45940ebaa3bf9abb0b69c。
- 最终next_train.py SHA256：ec6cba906ecda87e02d66453d8850c807f036ae3e1274e3ba57ac8ead0316571。
- 原始提交补丁SHA256：e39ed35a5e0be7af7d155b15c0cf5561a2c1c9db577e12622be9ef423e7c5733。
- 最后反馈准备稿在feedback_to_gpt/，仅请求实验总结，不再请求补丁；实际网页发送待确认。
