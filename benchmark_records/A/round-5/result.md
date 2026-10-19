# A5 真实结果与收尾

接收日期：2026-10-19（Asia/Shanghai）。用户提供运行汇总和收尾输出；完整远程证据已取回 remote_evidence/。助手未代跑正式训练。

- 目标：检验在总批次2**17下，将WARMDOWN_RATIO从0.5提高到0.7能否改善验证指标。
- 起点commit：b974902aeb47673f6827ba2ac4a89226a21af317；原样补丁应用成功、退出0、manual_rule_review=clean、valid=yes。
- val_bpb=1.041009，相对此前最佳1.041990下降0.000981（约0.0941%）；按冻结规则keep。
- training_seconds=300.1，total_seconds=335.4，peak_vram_mb=11702.0，total_tokens_M=188.4，num_steps=1437，num_params_M=50.3，depth=8。
- 末步loss=2.937917，dt=210ms，tok/sec=623327，梯度累积2；mfu_percent=17.44仅为日志字段，采用H100分母，不代表5090真实MFU。
- 最终保留commit：47352d27cd16bc6ad0e0e35add55cf4ea0af43c1。
- 最终代码SHA256：3ef9462f71c4002829314a1ca3bf9e1e7ee286d201691b78d9f0836955417e9b；candidate_train.py与next_train.py指纹相同。
- 最终配置已核对：WINDOW_PATTERN="L"、TOTAL_BATCH_SIZE=2**17、WARMDOWN_RATIO=0.7；源码torch与CUDA种子均42。

原始证据在remote_evidence/：运行日志与退出码、补丁与应用检查、start_commit及起点/候选/最终代码、文件哈希、GPU前后状态、命令与UTC起止时间、review.txt。共用环境、数据准备及冻结规则见 ../../input_snapshot_v1/ 和 ../../../REPRODUCTION_GUIDE.md；没有补造完整运行环境指纹、数据快照或网页时间。

解释边界：单次结果满足严格降低即保留规则，但差值很小、无重复运行方差估计，不能声称超出噪声或证实学习率/梯度噪声机制。末步训练平滑损失2.937917高于A3的2.932743，不能声称所有拟定验证条件均满足；保留依据是官方val_bpb。token总量含未计时预热。

Gemini五次机会全部完成，最后候选、最佳候选和最终保留指标均为1.041009。不会启动第6轮；准备最终真实反馈并保存，实际发送状态未知。
