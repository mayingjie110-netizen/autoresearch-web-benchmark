# A4 真实结果与收尾

接收日期：2026-10-19（Asia/Shanghai）；用户提供运行汇总和收尾输出，完整远程证据已取回 remote_evidence/。助手只取回、核对和归档证据，未执行正式训练。

- 改动：TOTAL_BATCH_SIZE 从 2**17 减至 2**16；窗口仍为 L，梯度累积从2降至1。
- 补丁应用成功，退出0；manual_rule_review=clean，valid=yes。
- val_bpb=1.048104，高于此前最佳1.041990，差值+0.006114（约+0.59%）；按冻结规则回退。
- training_seconds=300.1，total_seconds=334.7，peak_vram_mb=11550.0。
- total_tokens_M=183.8，num_steps=2804，num_params_M=50.3，depth=8。
- 末步loss=2.936259，dt=108ms，tok/sec=609582；日志mfu_percent=17.07采用H100分母，不能代表5090真实利用率。
- 保留最佳仍为A3的1.041990；next_commit=b974902aeb47673f6827ba2ac4a89226a21af317。
- 已核对 next_train.py 恢复 TOTAL_BATCH_SIZE=2**17；它是第5轮唯一权威起点。

解释边界：本次更新次数增多而验证指标变差，未支持该候选进一步改善的假设。单次运行不能确定全局最优批次、临界批次或噪声机制；token总量含未计时预热，不能直接据总量差分精确估算优化器耗时。

证据索引：完整日志 run.log、退出码 exit_code.txt、提交补丁 model.patch、起点 start_train.py / start_commit.txt、候选 candidate_train.py、代码指纹 file_hashes.txt、命令 command.txt、GPU前后状态 gpu-before.txt / gpu-after.txt、UTC起止时间、决定 review.txt、后续起点 next_train.py，均在 remote_evidence/。共同输入和环境规则见 ../../input_snapshot_v1/。种子及数据处理以固定源码和共享快照为准，不补造缺失的独立数据指纹或完整运行时环境快照。

原始 status.txt 仍为 NEEDS_REVIEW，而后续 review.txt 已明确有效并回退；保留两份原件，完成状态以收尾 review.txt 为准。

下一步：提供第4轮真实反馈和已回退代码给Gemini，请求第5/5轮。准备好的反馈不等于已实际发送。
