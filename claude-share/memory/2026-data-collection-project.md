---
name: 2026-data-collection-project
description: 数据采集26 项目——2026 状态数据采集会议 PPT 的工作方式（AAA.pptx 为新增页容器，原版不动，用户手动合并）
metadata: 
  node_type: memory
  type: project
  originSessionId: ea386eb8-f767-45f1-b319-fb99f103f975
---

`A_teacher/数据采集26/`（2026 年状态数据采集会议材料）工作约定：

- **原版 `2026数据采集会议.pptx`（31 页，28MB）不做任何修改**；所有新增页面写入 `AAA.pptx`（2026-10-08 完成 12 页：原 2 页"三、数据采集注意事项" + 本科指标对照表 7 页 + 协调会 3 页），由用户手动将页面合并进原版。
- 本科对照表数据源 `本科指标汇总对照表9.22修改.xlsx`：PPT 只取 B/D 两列（本科专业/本科学校），删"达标/争优"列（用户决定）→ 因此 2 条仅存在于该列的指标（兼职教师占比≤30%、行业导师占比≥25%）被省略。
- 该目录尚未登记进 `A_teacher/CLAUDE.md` 子项目清单。
- 构建脚本在 `/tmp/build_aaa.py`（从 xlsx 提取→复制 slide1 模板页→python-pptx 填充），原始备份 `/tmp/AAA_backup.pptx`；如需长期保留应拷入项目目录。
- 技术要点：本机 LibreOffice 渲染 pptx 表格**不会自动撑高行**，行高必须按内容显式计算（CJK 字符按 1.15em 宽估算、行高系数 1.35、每行 +0.12" 余量、≥10 行单元格再 +0.1"），否则多行单元格最后一行会被行线裁切。QA 用 venv-image 的 cv2 做像素级行线间距验证。
