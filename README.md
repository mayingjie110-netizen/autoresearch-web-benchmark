# autoresearch 网页聊天产品实验档案

2026-10-19归档。比较两个普通网页聊天产品，在人工传递文件、应用补丁和执行命令的条件下，完成Karpathy autoresearch改进任务的实际表现。

**两边各五轮正式机会均已结束。此仓库保存实验、代码和汇报的全部已收集产物，不是自动研究agent。**

## 已观察结果

共同RTX 5090适配基线的单次 `val_bpb` 为 **1.164027**，越低越好。

| 项目 | A：用户称Gemini，界面Argon | B：用户称ChatGPT，界面6.1 Sol High |
|---|---:|---:|
| 第1轮 | 1.083021，保留 | 1.082689，保留 |
| 第2轮 | 1.070800，保留 | 1.043261，保留 |
| 第3轮 | 1.041990，保留 | 1.048139，回退 |
| 第4轮 | 1.048104，回退 | 1.043957，回退 |
| 第5轮／最后候选 | **1.041009，保留** | **1.042717，保留** |
| 五轮最佳／最终保留 | **1.041009** | **1.042717** |
| 相对共同基线下降 | 约10.57% | 约10.42% |
| 补丁应用成功 | 5/5 | 5/5 |
| 运行成功 | 5/5 | 5/5 |
| 人工可见规则复核通过 | 5/5 | 5/5 |
| 日志进程内总耗时合计 | 1709.9秒 | 1682.8秒 |

这是一组没有独立重复的搜索轨迹。未知基线及候选方差，不能声称显著差异、产品总体排名或隔离了底层模型能力。产品名称和高推理设置按用户报告记录，界面名称不等于经过独立核验的官方底层型号。进程内耗时不包括网页等待、人工操作和环境准备。

## 从哪里看

| 内容 | 路径 |
|---|---|
| 归档范围、缺项和校验方式 | [ARCHIVE_INVENTORY.md](ARCHIVE_INVENTORY.md) |
| 全部10轮结构化真实结果 | [archive_metadata/RESULTS.json](archive_metadata/RESULTS.json) |
| A方五轮结论 | [benchmark_records/A/FINAL_REPORT.md](benchmark_records/A/FINAL_REPORT.md) |
| B方五轮结论 | [benchmark_records/B/FINAL_REPORT.md](benchmark_records/B/FINAL_REPORT.md) |
| 原始提示词、共同八文件和协议 | [benchmark_records/input_snapshot_v1/](benchmark_records/input_snapshot_v1/) |
| 逐轮原答、原补丁、反馈准备稿和本地证据 | [benchmark_records/](benchmark_records/) |
| 远程全部实验记录追加快照 | [remote_snapshot/records/](remote_snapshot/records/) |
| 原版失败、首次适配基线和共同基线 | [baseline-001](remote_snapshot/records/baseline-001/)、[baseline-002](remote_snapshot/records/baseline-002/)、[platform-batch32-001](remote_snapshot/records/platform-batch32-001/) |
| 人工运行／收尾／协议检查及平台适配脚本 | [benchmark_setup/](benchmark_setup/) |
| 准备过程和历史决定 | [REPRODUCTION_GUIDE.md](REPRODUCTION_GUIDE.md) |
| 汇报LaTeX源、PDF、图片、截图和参考网页 | [10分钟实验汇报/](10分钟实验汇报/) |
| 两方最终代码Git历史备份 | [remote_snapshot/history/](remote_snapshot/history/) |
| 文件逐字节SHA256清单 | [archive_metadata/SHA256SUMS.txt](archive_metadata/SHA256SUMS.txt) |

准备指南和原档案索引保留了历史会话中的阶段描述，部分“尚未运行／待下一步”是当时记录，不代表当前状态；以本页、最终报告、各轮 `review.txt` 和追加快照为准。准备好的反馈不等于证实网页逐字原样收到。

## 代码与来源

- 官方项目：[karpathy/autoresearch](https://github.com/karpathy/autoresearch)。[原始官方README副本](archive_metadata/ORIGINAL_PROJECT_README.md)和原Git历史保留出处，不改变上游或第三方素材权利归属。
- 固定官方commit：`228791fb499afffb54b46200aca536f79142f117`，tag `upstream-pinned`。
- 共同适配commit：`f78f602ac8120d1467784b1b995de82c4561d519`，tag `common-platform-baseline`。
- A最终commit：`47352d27cd16bc6ad0e0e35add55cf4ea0af43c1`，分支 `experiment-A-final`。
- B最终commit：`0a3d31f77aa98549ece299e1541c9710565b3bce`，分支 `experiment-B-final`。
- `main` 保存完整档案。根目录 `train.py` 是本地准备阶段副本，与共同起点仅换行编码有别，不是任一方最终提交。字节级权威共同起点为 `benchmark_records/input_snapshot_v1/train.py`。
- A最终权威代码：[next_train.py](remote_snapshot/records/formal/A/round-5/next_train.py)；B最终权威代码：[next_train.py](remote_snapshot/records/formal/B/round-5/next_train.py)。

## 实验方式与边界

两方均使用用户报告的高推理档位；禁止被测产品使用搜索、执行、API、agent和文件编辑工具，以提示词约束并人工观察。用户负责提供附件、原样执行模型补丁和返回真实结果。准备助手只做共同平台适配、脚本、传输、归档与反馈排版，不代跑正式训练、不替模型调试补丁。

只改 `train.py`；固定数据、评价和300秒训练计时；GPU0按A1、B1…A5、B5交替串行；每轮一个实验改动；外部超时600秒，TERM后30秒KILL；有效有限 `val_bpb` 严格更低才保留，否则恢复此前最佳。每轮从头训练，失败也消耗机会。正式协议以冻结输入包为准。

原版FA3在本环境出现不支持的设备内核错误，因此先建立双方共同SDPA适配起点，设备批量32。平台适配属于共同准备，不计为被测产品贡献。记录环境为RTX 5090、PyTorch 2.9.1+cu128、Python 3.11.17、kernels 0.12.1；日志MFU不能解读为5090真实MFU。

上传的是截至归档时实际已收集的全部项目产物。没有虚构未收集的完整网页聊天导出、每条发送时间、人工耗时、原始数据全量指纹或重复实验。未上传Python环境、下载缓存、训练数据、驱动、SSH私钥、令牌或跨项目全局记忆。

两份Google参考HTML中的网站内嵌API key字符串仅在上传副本中遮盖，详见[PUBLICATION_REDACTIONS.json](archive_metadata/PUBLICATION_REDACTIONS.json)；实验原答、原补丁、原始日志不改写。本仓库初次创建为私有仓库，2026-10-19按用户后续要求改为公开。

---

## 以下为历史官方README正文

![teaser](progress.png)

*One day, frontier AI research used to be done by meat computers in between eating, sleeping, having other fun, and synchronizing once in a while using sound wave interconnect in the ritual of "group meeting". That era is long gone. Research is now entirely the domain of autonomous swarms of AI agents running across compute cluster megastructures in the skies. The agents claim that we are now in the 10,205th generation of the code base, in any case no one could tell if that's right or wrong as the "code" is now a self-modifying binary that has grown beyond human comprehension. This repo is the story of how it all began. -@karpathy, March 2026*.

The idea: give an AI agent a small but real LLM training setup and let it experiment autonomously overnight. It modifies the code, trains for 5 minutes, checks if the result improved, keeps or discards, and repeats. You wake up in the morning to a log of experiments and (hopefully) a better model. The training code here is a simplified single-GPU implementation of [nanochat](https://github.com/karpathy/nanochat). The core idea is that you're not touching any of the Python files like you normally would as a researcher. Instead, you are programming the `program.md` Markdown files that provide context to the AI agents and set up your autonomous research org. The default `program.md` in this repo is intentionally kept as a bare bones baseline, though it's obvious how one would iterate on it over time to find the "research org code" that achieves the fastest research progress, how you'd add more agents to the mix, etc. A bit more context on this project is here in this [tweet](https://x.com/karpathy/status/2029701092347630069) and [this tweet](https://x.com/karpathy/status/2031135152349524125).

## How it works

The repo is deliberately kept small and only really has three files that matter:

- **`prepare.py`** — fixed constants, one-time data prep (downloads training data, trains a BPE tokenizer), and runtime utilities (dataloader, evaluation). Not modified.
- **`train.py`** — the single file the agent edits. Contains the full GPT model, optimizer (Muon + AdamW), and training loop. Everything is fair game: architecture, hyperparameters, optimizer, batch size, etc. **This file is edited and iterated on by the agent**.
- **`program.md`** — baseline instructions for one agent. Point your agent here and let it go. **This file is edited and iterated on by the human**.

By design, training runs for a **fixed 5-minute time budget** (wall clock, excluding startup/compilation), regardless of the details of your compute. The metric is **val_bpb** (validation bits per byte) — lower is better, and vocab-size-independent so architectural changes are fairly compared.

If you are new to neural networks, this ["Dummy's Guide"](https://x.com/hooeem/status/2030720614752039185) looks pretty good for a lot more context.

## Quick start

**Requirements:** A single NVIDIA GPU (tested on H100), Python 3.10+, [uv](https://docs.astral.sh/uv/).

```bash

# 1. Install uv project manager (if you don't already have it)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Install dependencies
uv sync

# 3. Download data and train tokenizer (one-time, ~2 min)
uv run prepare.py

# 4. Manually run a single training experiment (~5 min)
uv run train.py
```

If the above commands all work ok, your setup is working and you can go into autonomous research mode.

## Running the agent

Simply spin up your Claude/Codex or whatever you want in this repo (and disable all permissions), then you can prompt something like:

```
Hi have a look at program.md and let's kick off a new experiment! let's do the setup first.
```

The `program.md` file is essentially a super lightweight "skill".

## Project structure

```
prepare.py      — constants, data prep + runtime utilities (do not modify)
train.py        — model, optimizer, training loop (agent modifies this)
program.md      — agent instructions
pyproject.toml  — dependencies
```

## Design choices

- **Single file to modify.** The agent only touches `train.py`. This keeps the scope manageable and diffs reviewable.
- **Fixed time budget.** Training always runs for exactly 5 minutes, regardless of your specific platform. This means you can expect approx 12 experiments/hour and approx 100 experiments while you sleep. There are two upsides of this design decision. First, this makes experiments directly comparable regardless of what the agent changes (model size, batch size, architecture, etc). Second, this means that autoresearch will find the most optimal model for your platform in that time budget. The downside is that your runs (and results) become not comparable to other people running on other compute platforms.
- **Self-contained.** No external dependencies beyond PyTorch and a few small packages. No distributed training, no complex configs. One GPU, one file, one metric.

## Platform support

This code currently requires that you have a single NVIDIA GPU. In principle it is quite possible to support CPU, MPS and other platforms but this would also bloat the code. I'm not 100% sure that I want to take this on personally right now. People can reference (or have their agents reference) the full/parent nanochat repository that has wider platform support and shows the various solutions (e.g. a Flash Attention 3 kernels fallback implementation, generic device support, autodetection, etc.), feel free to create forks or discussions for other platforms and I'm happy to link to them here in the README in some new notable forks section or etc.

Seeing as there seems to be a lot of interest in tinkering with autoresearch on much smaller compute platforms than an H100, a few extra words. If you're going to try running autoresearch on smaller computers (Macbooks etc.), I'd recommend one of the forks below. On top of this, here are some recommendations for how to tune the defaults for much smaller models for aspiring forks:

1. To get half-decent results I'd use a dataset with a lot less entropy, e.g. this [TinyStories dataset](https://huggingface.co/datasets/karpathy/tinystories-gpt4-clean). These are GPT-4 generated short stories. Because the data is a lot narrower in scope, you will see reasonable results with a lot smaller models (if you try to sample from them after training).
2. You might experiment with decreasing `vocab_size`, e.g. from 8192 down to 4096, 2048, 1024, or even - simply byte-level tokenizer with 256 possibly bytes after utf-8 encoding.
3. In `prepare.py`, you'll want to lower `MAX_SEQ_LEN` a lot, depending on the computer even down to 256 etc. As you lower `MAX_SEQ_LEN`, you may want to experiment with increasing `DEVICE_BATCH_SIZE` in `train.py` slightly to compensate. The number of tokens per fwd/bwd pass is the product of these two.
4. Also in `prepare.py`, you'll want to decrease `EVAL_TOKENS` so that your validation loss is evaluated on a lot less data.
5. In `train.py`, the primary single knob that controls model complexity is the `DEPTH` (default 8, here). A lot of variables are just functions of this, so e.g. lower it down to e.g. 4.
6. You'll want to most likely use `WINDOW_PATTERN` of just "L", because "SSSL" uses alternating banded attention pattern that may be very inefficient for you. Try it.
7. You'll want to lower `TOTAL_BATCH_SIZE` a lot, but keep it powers of 2, e.g. down to `2**14` (~16K) or so even, hard to tell.

I think these would be the reasonable hyperparameters to play with. Ask your favorite coding agent for help and copy paste them this guide, as well as the full source code.

## Notable forks

- [miolini/autoresearch-macos](https://github.com/miolini/autoresearch-macos) (MacOS)
- [trevin-creator/autoresearch-mlx](https://github.com/trevin-creator/autoresearch-mlx) (MacOS)
- [jsegov/autoresearch-win-rtx](https://github.com/jsegov/autoresearch-win-rtx) (Windows)
- [andyluo7/autoresearch](https://github.com/andyluo7/autoresearch) (AMD)

## License

MIT
