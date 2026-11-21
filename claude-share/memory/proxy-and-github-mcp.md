---
name: proxy-and-github-mcp
description: 可用代理是 7891 端口（xray），git 全局配置还指向已死的 7890；GitHub 托管 MCP 只能用 PAT 认证不能 OAuth
metadata: 
  node_type: memory
  type: project
  originSessionId: 04b961c3-157a-4995-be4b-c1bae658bd7f
---

- **可用代理**：`127.0.0.1:7891`，xray mixed 入站（HTTP/SOCKS 双协议），由 v2rayN 启动（/media/data/wzp-home/Public/v2rayn）。注意：v2rayN 刚启动后节点需要约 1-2 分钟才通（表现为 CONNECT 建立但无数据流，curl 超时）。git 全局 http.proxy 仍指向 127.0.0.1:7890（已废弃无服务），克隆 GitHub 时用 `git -c http.proxy=http://127.0.0.1:7891 clone ...`。
- **GitHub MCP 服务器**：已配置于用户级（~/.claude.json，`claude mcp list` 可见）。要点：托管版（api.githubcopilot.com/mcp）**不支持 OAuth login**（报 Incompatible auth server: does not support dynamic client registration），必须 PAT 认证——`claude mcp add-json github '{"type":"http","url":"https://api.githubcopilot.com/mcp","headers":{"Authorization":"Bearer <PAT>"}}'`。api.githubcopilot.com 可直连无需代理。
