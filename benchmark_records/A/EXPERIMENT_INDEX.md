# Gemini（A）正式实验索引

本索引仅汇总A方已确认正式运行；完整事实以各轮原始证据与review.txt为准。初始共同输入见 ../input_snapshot_v1/；环境与平台准备见 ../../REPRODUCTION_GUIDE.md。实际网页完整输入及发送时间仍有缺失，不推定为已核实。

| 轮次 | 改动 | 候选val_bpb | 收尾 | 保留最佳 | 证据 |
|---|---|---|---|---|---|
| A1 | 窗口SSSL→L | 1.083021 | keep | 1.083021 | round-1/remote_evidence/ |
| A2 | 总批次2**19→2**18 | 1.070800 | keep | 1.070800 | round-2/remote_evidence/ |
| A3 | 总批次2**18→2**17 | 1.041990 | keep | 1.041990 | round-3/remote_evidence/ |
| A4 | 总批次2**17→2**16 | 1.048104 | revert | 1.041990 | round-4/remote_evidence/ |
| A5 | 冷却比例0.5→0.7 | 1.041009 | keep | 1.041009 | round-5/remote_evidence/ |

A4接收日期2026-10-19，valid=yes、manual_rule_review=clean、退出0；完整记录见 round-4/result.md，真实命令、日志、补丁、代码状态、数据/配置相关源码、GPU状态、时间和决定均引用本轮证据及共同快照。未另外证明完整环境/数据指纹或每次网页操作；无重复运行方差估计。下一轮为最后一次机会A5，必须从A4收尾生成的next_train.py开始。

2026-10-19后续：A5已经完成并收尾，valid=yes、clean、退出0、keep；最终commit为47352d27cd16bc6ad0e0e35add55cf4ea0af43c1。五轮全部结束，不再进行第6轮。完整结果见round-5/result.md及FINAL_REPORT.md；历史A4条目的下一步已完成。
