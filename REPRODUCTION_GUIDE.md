# autoresearch 网页产品 benchmark：准备记录

## 当前目标与边界

比较两个普通网页聊天产品提出 autoresearch 实验改动并利用人工反馈迭代的表现。
被测产品不使用 API、agent、代码执行或文件操作工具。用户手动应用补丁、运行命令，原样反馈结果。
准备助手可以准备共同平台补丁；不得把这份补丁算作某一被测产品的贡献。
尚未冻结正式轮数、重复方式、评分阈值或最终运行协议，不能开始正式比较。

## 已确认来源与环境

- 官方来源：https://github.com/karpathy/autoresearch
- 固定 commit：228791fb499afffb54b46200aca536f79142f117。
- 远程根目录：/data2/home/yingjie/autoresearch；源码：repo/。
- 用户报告 Ubuntu 24.04 x86_64；RTX 5090 两张，各 32607 MiB。
- 驱动 570.172.08；Python 3.11.17；PyTorch 2.9.1+cu128；kernels 0.12.1；uv 0.13.1。
- 用户手动验证 torch 可见两张卡，计算架构 (12, 0)，PyTorch 编译架构列表包含 sm_120。
- 数据准备由用户执行并报告 Done! Ready to train；完整准备日志尚未收集。
- 默认 ~/.cache/autoresearch 符号链接到项目 cache/autoresearch，用户确认建立成功。
- cuDNN 9.10.2.21 曾下载超时；用户从清华镜像下载同版本 wheel 并确认校验步骤完成，随后重新 uv sync。
- 共享 GPU 曾获用户接受；后来用户报告两卡空闲。负载不能视为永久保证，测量时仍需记录。

## 官方规则与 benchmark 改编

官方：只改 train.py，不改 prepare.py 或评价，不新增依赖；300 秒计时训练；目标降低 val_bpb；program.md 规定超过 10 分钟按失败处理。
实现：计时累计排除 step 编号 0 到 10 的耗时；进程实际总耗时包含额外编译、预热与评价。
网页改编：人工执行、逐轮反馈、有限预算等是 benchmark 自定规则，需在正式开始前冻结。

## 原版平台失败证据

用户在 GPU 0 运行原版 baseline-001，报告退出码 1：

```
CUDA error (/build/source/flash-attn/flash_fwd_launch_template.h:192):
no kernel image is available for execution on the device
```

这是原版在当前环境下的 Flash Attention 执行失败，不是可评分的 val_bpb。
不得覆盖 records/baseline-001；完整远程日志仍由用户保存，尚未取得本地副本。
不能推断所有 Flash Attention 构建均不支持 5090，或 300 秒预算仅适用于 H100。

## 2026-10-19 共同平台适配候选 v1（未运行验证）

用户已接受任务范围为官方固定 commit 的 RTX 5090 适配版。

- 将外部 FA3 调用替换为 PyTorch 原生 scaled_dot_product_attention，无新增依赖。
- 输入输出仍为 B,T,H,D；内部转置为 B,H,T,D。
- 全窗口使用 is_causal=True；短窗口允许 i-left <= j <= i，包含两端，排除未来 token。
- 支持原有 n_kv_head 配置对应的 GQA；只支持当前任务的等长因果 self-attention。
- DEVICE_BATCH_SIZE 从 128 暂改为 8，作为 32 GB 平台探索性起点，不声称最优或已足够。
- TOTAL_BATCH_SIZE=2**19 不变，梯度累积从 2 改为 32。
- DEPTH、WINDOW_PATTERN、学习率、随机种子、MAX_SEQ_LEN、TIME_BUDGET、EVAL_TOKENS 及 prepare.py 均不改。
- 官方 mfu_percent 仍使用 H100 峰值分母，不能作为 5090 的真实算力利用率解释。
- SDPA 可能选取不同后端，短窗口显式遮罩可能较慢或占显存；实际性能、数值与完整运行尚未验证。
- 批量改变可能影响浮点累计、吞吐及最终指标；适配基线不能与 H100 数字直接比较。

## 阶段与人工验证

1. 将 benchmark_setup/rtx5090-v1.patch 上传到远程同名目录。先 git apply --check，再 git apply；必须是固定官方版本且无冲突。
2. 上传 benchmark_setup/check_platform_attention.py，使用项目 Python、GPU 0 和已加载的 env.sh 手动运行。
3. 脚本只抽取适配函数，不导入 train.py 的训练主体；用逐行定义的独立参考计算验证输出与 Q/K/V 梯度，包含全窗口、零窗口、短窗口和 GQA。
4. 在长度 2048、head_dim=128、BF16 上检查 torch.compile 的前后向及有限值。仅小批量 smoke，不能证明完整模型显存足够。
5. 脚本成功必须显示 PLATFORM_ATTENTION_CHECK_PASSED；失败保留原始输出，不进入完整基线。
6. 再由用户运行完整适配基线，使用新的记录编号；检查退出码、val_bpb、计时、步数、显存等。不得复用 baseline-001 目录。
7. 单次成功后才设计重复基线和成本测量，再冻结比较协议。

常见失败：补丁上下文不匹配时先检查 commit 和改动；内核/编译错误保留日志；OOM 需单独记录下一版适配；超时区分编译预热与稳态训练，不静默延长规则。

以上检查脚本尚未运行，未报告测试通过。只有本地 Git diff 静态检查，不构成远程运行证据。

## 远程应用记录（2026-10-19）

用户明确授权准备助手直接修改远程文件。修改前通过 SSH 确认远程为固定 commit 且工作区干净；随后以 git apply --check 检查并应用 v1 补丁。

- 修改文件：/data2/home/yingjie/autoresearch/repo/train.py。
- 保存补丁：/data2/home/yingjie/autoresearch/records/rtx5090-v1-KVRA2a.patch。
- 修改后 train.py SHA256：816782269475151b292e62d8c779a480475bf2470458f35f4d4b884f62b5a8ec。
- 远程 git diff --check 通过；确认 prepare.py、pyproject.toml、uv.lock 相对 HEAD 未改变。
- 仅进行了文件修改及 Git 静态检查，没有运行 Python、数值检查或训练。
- 仍待用户手动验证注意力数值/梯度与完整基线，不能开始正式 benchmark。

## 2026-10-19 公开适配资料核查

用户后续报告注意力检查通过；完整输出尚未归档，适配完整训练结果尚未提供。

- 官方 autoresearch 远端 HEAD 再核对仍为 228791fb499afffb54b46200aca536f79142f117。
- FlashAttention 官方 README 将 FA3 定位于 Hopper，列出 H100/H800 要求；FA4 为 Hopper/Blackwell 的 CuTeDSL 实现。
  来源：https://github.com/Dao-AILab/flash-attention#flashattention-3-beta-release
- 本次读到 FA4 interface.py 包含 FlashAttentionForwardSm120、FlashAttentionBackwardSm120 及 window_size 参数；主分支查询 SHA 为 e7a6402a9ff099de5eb628ce207a88a3f0aa5378。抓取 main 文件与查询 SHA 为分开请求，未逐字节验证二者一致。
  来源：https://github.com/Dao-AILab/flash-attention/blob/main/flash_attn/cute/interface.py
- PyPI 查询 flash-attn-4 为 4.0.0b35，新增 CUTLASS DSL、TVM FFI、quack 等依赖；不能当成当前官方锁文件内的无依赖替换，尚未验证用户环境兼容性。
- autoresearch 社区 PR #115 “Added 5090 (32GB) support” 已关闭且未合入。已读取补丁：FA4 尝试加载，失败回退 SDPA；批量 128->64；SDPA 路径将 WINDOW_PATTERN 改为 L。因此不能直接作为保持官方 SSSL 的平台等价实现，也不能将该配置视为当前平台实测结论。
  来源：https://github.com/karpathy/autoresearch/pull/115
- 已查材料没有提供可直接用作本 benchmark 基线的同协议 5090 完整日志、方差与可复现 val_bpb。不是断言全网不存在。
- 当前 v1 批量 8 仍是保守猜测，不是文献确定值。SDPA 保留 SSSL，与 PR 的全窗口回退不同。尚未因检索结果修改远程文件或新增依赖。

## baseline-002：首次适配完整运行成功（用户回传，2026-10-19）

证据：C:/Users/MaYingjie/.codex/attachments/b4011b10-10a8-4b1b-83f2-c821cb19d489/Pasted text.txt。
用户按 GPU 0、v1 配置运行，回传 exit code 0、SSSL、深度 8、梯度累积 32，参数 50,332,176。

| 指标 | 值 |
|---|---|
| val_bpb | 1.168013 |
| training_seconds | 301.3 |
| total_seconds | 395.1 |
| peak_vram_mb | 3382.3 |
| total_tokens_M | 99.1 |
| num_steps | 189 |
| mfu_percent（H100 分母，不按真实 5090 MFU 解释） | 7.53 |

稳态日志约每步 1.69 秒，首步 33.586 秒。峰值指标仅是 PyTorch max_memory_allocated，非整卡总显存；总 token 包含不计时预热步骤。
运行成功且有有限最终指标，排除本配置的完整运行阻塞；单次不支持方差、稳定性或性能最优判断。300 秒阈值在完成一个 step 后检查，301.3 秒不单独视为违规。
建议先保持 v1 配置完成同卡重复，初步判断时间预算边界/步数变化；尚未冻结为正式 benchmark 的对照基线或正式重复次数。不代替数据指纹、远程源文件记录及 GPU 前后快照核对。

## 平台批量探索 v2：8 -> 32（2026-10-19）

用户要求暂不重复基线，接受先探索更大批量，并授权助手同步修改本地和远程源码。
仅 DEVICE_BATCH_SIZE 从 8 改为 32，总批量 2**19 不变，梯度累积从 32 变为 8。
远程增量补丁：records/batch8-to32-P7H6We.patch；远程 train.py SHA256：dafb24a0ed985ac462f5ddc902d471dffbe9b927aae5d780904eb34ab9a934d5。
git diff --check 通过。原 v1 补丁保留原样，不改写既有实验来源。v2 尚未运行，显存/吞吐/指标未知，不声称优于 v1。

## 网页输入包核验更新（2026-10-19）

后续用户回传批量32完整汇总：val_bpb 1.164027，training_seconds 301.5，total_seconds 383.8，peak_vram_mb 11710.0，199步，104.3M tokens。用户选择不重复基线，波动未知。
用户确认每边五轮、失败计次、严格降低保留否则回退；A=用户所称Gemini（截图Argon），B=用户所称ChatGPT（截图6.1 Sol High），均由用户报告高档位。用户选择跳过进一步产品身份核验，后台能力、订阅及精确模型版本未知。通过提示词禁止全部搜索和执行工具，不是技术禁用保证。
两边GPU0交替串行。用户已手动创建共同适配commit f78f602ac8120d1467784b1b995de82c4561d519。
本次SSH只读复核A/B均在该commit且工作区干净；train.py SHA256均为dafb24a0ed985ac462f5ddc902d471dffbe9b927aae5d780904eb34ab9a934d5。
本地输入包六个仓库文件已从远程A取回，避免本地CRLF/LF差异。五个未修改文件与固定官方commit的Git blob一致；platform.patch反向检查通过；八个上传文件生成SHA256SUMS.txt。规则与提示词同步用户最后约定。
尚未执行正式轮次；run_round.sh已提供且仅通过bash语法检查，保留/回退流程及最终完整检查仍需补齐，不声称正式协议已全部就绪。

## 固定人工流程补齐（2026-10-19）

已提供并上传run_round.sh、finish_round.sh；前者原样应用补丁和统一限时运行，后者只按真实分数/人工合规检查决定保留或恢复该轮起点，先保存候选证据；不替模型调试或搜索。
无补丁/可见违规也占轮，用--missing/--violation记录而不启动训练。严格A1 B1...顺序，每轮须收尾才能继续，重复归档拦截。
远程使用tmp/protocol-check-Zjg7gc中的独立虚拟仓库和假uv/GPU命令执行流程检查，覆盖改善/变差/持平/崩溃/缺失/无效补丁/违规/顺序/重复收尾，PROTOCOL_TESTS_PASSED。未运行真实训练，未动正式A/B代码。
操作说明在benchmark_setup/web-benchmark-v1/OPERATOR_GUIDE.md；记录表RESULTS_TEMPLATE.tsv。辅助材料不上传给模型。
冻结规则已更新。发送前只剩用户现场确认新聊天、设置、八文件成功上传且统一提示词不变；无需反复批准。单次基线波动未知、产品核验不足和不可见工具行为等限制保留。

## 正式材料档案（2026-10-19）

用户要求保存全部提示词、逐轮输入输出及证据供后续PPT使用。统一入口benchmark_records/README.md；初始包固定快照input_snapshot_v1/，后续按A/B和轮次归档。反馈准备稿与网页实际已发送输入严格分开，未取得内容显式列缺项。
A1原始运行材料已取回：val_bpb1.083021、退出0、374步，人工已执行收尾并keep，commit53b382b60bf6d81c46cd7f49ff9d946f70ca4432。B1原答/补丁已在工作区，远程序列已登记B1但其运行结果尚未收集。本次未运行训练或变更轮次状态。

## Gemini分支五轮完成（2026-10-19后续）

用户后续将本分支限定为只负责Gemini（A）。A1至A5全部有效退出0，依次val_bpb为1.083021、1.070800、1.041990、1.048104、1.041009；A4回退，其余保留。最终commit47352d27cd16bc6ad0e0e35add55cf4ea0af43c1，相对共同单次基线观察改善约10.57%，无重复方差或显著性结论。全部正式训练由用户执行，助手只提取补丁、传输和归档证据。A方已结束，不再请求新补丁；另一产品由其他分支协调，不在此更新。证据入口benchmark_records/A/EXPERIMENT_INDEX.md和FINAL_REPORT.md，逐轮实际反馈发送状态仍待网页导出或用户补证。
