# GPT B4 运行与回退记录

归档日期：2026-10-19（Asia/Shanghai）。用户手动运行及收尾后粘贴结果；助手随后从远程取回本轮完整21份证据文件。未代跑训练或收尾。

本轮为正式机会4/5。候选仅将 EMBEDDING_LR 从0.6降低至0.2；原始补丁见model.patch，实际应用记录见remote_evidence/。起点commit为659575bc6c5e95f98bfd4c280881c726d801c721。

| 项目 | 结果 |
|---|---|
| exit_code | 0 |
| val_bpb | 1.043957 |
| training_seconds | 300.2 |
| total_seconds | 335.3 |
| peak_vram_mb | 11702.0 |
| mfu_percent（日志值） | 17.45 |
| total_tokens_M | 188.6 |
| num_steps | 1439 |
| num_params_M | 50.3 |
| depth | 8 |
| 梯度累积次数 | 2 |
| 人工规则复核 | clean（用户报告，不能证明不可见行为） |
| valid | yes |
| decision | revert |
| best_val_bpb | 1.043261 |
| next_commit | 659575bc6c5e95f98bfd4c280881c726d801c721 |

候选较保留最佳高0.000696，按冻结规则回退，机会已消耗。下一轮权威代码已恢复EMBEDDING_LR=0.6、TOTAL_BATCH_SIZE=2**17、DEVICE_BATCH_SIZE=32；next_train.py与B2保留代码SHA256一致。单次观察不能证明降低嵌入学习率普遍有害，也不能判断统计显著性。

运行命令、GPU前后状态、起止UTC、随机种子所在源文件、候选/起点/下一轮源代码、应用日志与文件指纹均在remote_evidence/。数据与共享环境遵守冻结输入包及准备记录；本次未另行运行环境探测。mfu_percent使用原脚本口径，不作为5090实际硬件利用率。

remote_evidence/status.txt为运行阶段遗留的NEEDS_REVIEW；完成收尾的依据为review.txt及远程HEAD只读核验，不改写原证据。

- 原日志SHA256：be2504ff96f1dcec208b80ae3039db2cd025854725c9db85623b982345f2d617。
- next_train.py SHA256：f1fd24154aa4f2e5af470dfb6093dd87e3a693830ed810174ec07b2ae15777df。
- 反馈准备稿及两份附件在feedback_to_gpt/；实际网页发送尚未确认。
