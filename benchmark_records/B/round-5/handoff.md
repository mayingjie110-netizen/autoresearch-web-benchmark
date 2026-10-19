# B5 提交交接核验

- 日期：2026-10-19（Asia/Shanghai）。
- 原答、原始补丁、接收记录已上传至 `/data2/home/yingjie/autoresearch/records/submissions/B5/`；远程与本地三份文件SHA256一致。
- model.patch SHA256：e39ed35a5e0be7af7d155b15c0cf5561a2c1c9db577e12622be9ef423e7c5733。
- 上传后只读核验：B HEAD为659575bc6c5e95f98bfd4c280881c726d801c721，git status --porcelain无输出。
- 前序机会收尾文件存在；未读取另一产品结果。B5运行目录不存在，未启动。
- GPU0核验瞬时状态：utilization.gpu=0%，memory.used=0 MiB；这不保证后续持续空闲。
- 原协议不变：单GPU0交替串行，300秒训练预算、600秒外部超时；未采用此前撤回的两卡并行提议。
- 本轮仅提议将WARMDOWN_RATIO从0.5改为0.8；尚未应用补丁或运行训练。严格保留阈值为val_bpb < 1.043261。

用户手动运行：

```bash
bash /data2/home/yingjie/autoresearch/records/run_round.sh B 5 /data2/home/yingjie/autoresearch/records/submissions/B5/model.patch
```

运行后，用户确认未观察到违反冻结规则的行为时手动收尾：

```bash
bash /data2/home/yingjie/autoresearch/records/finish_round.sh B 5 clean
```

B5为最后一次正式机会，收尾后不再启动第6轮。
