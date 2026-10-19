# 归档范围与可复现边界

用户明确要求将本次实验的一切产出汇总上传自己的GitHub账户，因此本次归档在两方实验完成后合并A/B材料。此前会话各自负责一方的范围是实验期间约束，不是把另一方结果反馈给被测产品的授权。本次没有向任一被测产品发送另一方结果。

## 已收集材料

1. 本地 `D:/Desktop/autoresearch` 全部403个文件（不含 `.git` 内部文件），涵盖源码、输入包、脚本、十轮原答与补丁、证据和汇报素材。复制时的路径、大小及SHA256在 `archive_metadata/SOURCE_LOCAL_FILES.json`。
2. 远程 `/data2/home/yingjie/autoresearch/records` 全部268个文件，含正式实验、原版失败、首次适配基线和共同基线。原始传输包 `remote_snapshot/records.tar.gz` 同时保留，解包内容位于 `remote_snapshot/records/`。
3. 比较状态：共同commit、平台补丁、交替序列和最终最佳值，位于 `remote_snapshot/comparison-state/`。
4. 准备源码、`env.sh`、未提交平台补丁、HEAD/status和归档当刻系统/GPU状态，位于 `remote_snapshot/prepared-repo/`。归档时GPU状态不替代逐轮快照。
5. A/B完整可达代码历史：`remote_snapshot/history/A.bundle`、`B.bundle`，已用 `git bundle verify` 核对，并导入 `experiment-A-final`、`experiment-B-final` 分支。原官方历史也保留。
6. 准备指南引用的首次适配基线粘贴附件，另存 `archive_metadata/user-provided-attachments/baseline-002-user-paste.txt`。

远程快照时间见 `remote_snapshot/snapshot_utc.txt`，为2026-10-19T05:25:32Z；不是网页生成时间。

本地既有证据及追加远程快照有意重复保存。某些本地旧目录缺少当时尚未收尾的文件，最新正式收尾查看 `remote_snapshot/records/formal/{A,B}/round-N/review.txt`。原档案索引另有副本 `archive_metadata/ORIGINAL_RECORDS_README.md`，旧记录不抹除。

## 完整性核验

`archive_metadata/SHA256SUMS.txt` 列出除自身和 `.git` 元数据以外全部发布文件的逐字节SHA256。`.gitattributes` 禁用自动换行转换，保护日志、补丁及源码原字节。SHA256不是外部可信时间戳，也不证明网页来源真实性。

十轮日志的最终 `val_bpb` 均已与 `review.txt` 核对，本地提交补丁也逐字节核对远程执行补丁。共同起点、A最终代码、B最终代码SHA256分别为：

```text
dafb24a0ed985ac462f5ddc902d471dffbe9b927aae5d780904eb34ab9a934d5  benchmark_records/input_snapshot_v1/train.py
3ef9462f71c4002829314a1ca3bf9e1e7ee286d201691b78d9f0836955417e9b  remote_snapshot/records/formal/A/round-5/next_train.py
ec6cba906ecda87e02d66453d8850c807f036ae3e1274e3ba57ac8ead0316571  remote_snapshot/records/formal/B/round-5/next_train.py
```

代码历史 `.bundle` 可独立验证和在新目录恢复。不要在已完成实验的原目录重跑脚本或覆盖证据。其他机器需要重新配置绝对路径和依赖，再做单独编号的复现。

## 排除与发布副本变更

未复制Python环境、uv二进制与缓存、训练数据/分词器大文件、GPU编译缓存、SSH密钥、登录令牌或跨项目记忆；这些不是本次模型实验输出。依赖和下载信息保留在锁文件、准备指南和脚本。没有额外已知训练checkpoint被生成或收集，不声称归档了不存在的权重。

两份Google开发文档HTML含网页前端自身API key字符串；上传副本替换成占位符，本地原文件不动，原/发布文件hash和替换数见 `archive_metadata/PUBLICATION_REDACTIONS.json`。实验回答、补丁及日志不改写。

顶层README和本清单属于新增导航；原官方README保存在 `archive_metadata/ORIGINAL_PROJECT_README.md`，源码和参考素材权利归属不改变，未擅自添加新许可证。

## 缺失的事实

- 全部网页会话完整导出、实际附件顺序、完整工具记录和准确发送/回复时间尚未取得。
- 反馈准备稿不等于逐字实际发送证据，最后模型总结未收集。
- 精确官方产品身份、版本及订阅未独立核验，名称按用户和截图记录。
- 没有独立重复，未知方差，不能作显著性检验或稳定产品排名。
- 没有新增数据全量指纹或逐轮完整环境镜像，不能声称位级完全可复现。
- 人工操作、网页等待和准备总成本不完整，不能用日志训练时间替代。

归档只做汇总、指纹核验、代码历史备份和Git发布，没有新增训练或改变正式结果。
