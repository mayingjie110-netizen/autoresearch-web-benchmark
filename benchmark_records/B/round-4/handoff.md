# B4 提交交接核验

- 日期：2026-10-19（Asia/Shanghai）。
- 原答、原始补丁、接收记录已上传至 `/data2/home/yingjie/autoresearch/records/submissions/B4/`；远程与本地三份文件 SHA256 一致。
- model.patch SHA256：`ce142059c1eee74b55b6728e1af01e8d2028c1b541d78d9b05e009f2c38923e4`。
- 上传后只读核验：B HEAD 为 `659575bc6c5e95f98bfd4c280881c726d801c721`，`git status --porcelain` 无输出。
- 已确认前序机会的收尾文件存在；未读取另一产品的实验结果。
- 仅调整 EMBEDDING_LR 0.6 → 0.2；最佳保留值仍为 1.043261；性能收益为被测模型假设。
- 本次未应用补丁、未运行训练、未代替人工进行约束审核。等待用户手动运行及收尾。

```bash
bash /data2/home/yingjie/autoresearch/records/run_round.sh B 4 /data2/home/yingjie/autoresearch/records/submissions/B4/model.patch
```

运行后，用户确认未观察到违反冻结规则的行为时：

```bash
bash /data2/home/yingjie/autoresearch/records/finish_round.sh B 4 clean
```
