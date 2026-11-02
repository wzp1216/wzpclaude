---
name: libreoffice-parser-diagnosis
description: "LibreOffice 24.2.7.2 完好无损；\"解析器坏了/ filter 链坏了\"是 2026-10-25 的误诊——.wps 文字文档转 xlsx/csv 报 no export filter 属预期行为"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 81f5d381-a890-48fa-bbf6-9c2c3e9ad742
---

2026-10-25 排查结论：LibreOffice 未损坏，无需修复。

**验证矩阵（全部通过）**：txt→pdf、docx→txt、xlsx→csv、pptx→pdf、.wps(文字)→txt、全新 profile 下转换均正常。

**误诊根因**：用户下载的 `chengguo.wps`（数据采集26项目的成果汇总表）实为 WPS 文字文档（OLE2/Word97 底层，`file` 可确认），把它 `--convert-to xlsx/csv` 时报 `Error: no export filter` —— 这是 Writer 模块没有表格导出过滤器的**预期行为**，不是安装损坏。

**正确处理路径**（今后遇 .wps 直接照做，别再怀疑 LO）：
- WPS 文字（.wps）→ `soffice --headless --convert-to txt --outdir /tmp 文件.wps`
- WPS 表格扩展名是 `.et`、文字是 `.wps`、演示是 `.dps`，先用 `file` 命令确认底层格式再选转换目标
- Claude Code 的 Read 工具不能直接读 OLE2 二进制（.wps/.doc），会输出乱码，须先经 soffice 转文本

关联：[[2026-data-collection-project]]
