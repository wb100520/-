# 梯子 — 可组装的便携软件下载清单与自动化脚本

说明
- 这个仓库模板包含“下载与组装脚本 + 清单（manifest） + 便携目录模板”，供你在本地或 CI 上运行一次脚本后把官方安装包下载到仓库并生成“解压即用”的便携包。
- 我不会在仓库中提交第三方闭源大二进制文件；脚本会在你本地运行并从官方站点下载文件（并进行校验），以确保来源可信与合规。

重要法律与合规提醒
- 请在使用前确认你所在司法辖区允许使用这些工具并确认用途合规（远程办公、隐私保护或学术研究等）。  
- 你必须遵守各软件的许可条款与目标服务的使用规则。作者/维护者不支持或协助任何违法用途。

默认包含的软件（你已选择）
- WireGuard — Windows / macOS / Linux  
  官方站点：https://www.wireguard.com/install/
- Tor Browser — Windows / macOS / Linux  
  官方站点：https://www.torproject.org/download/
- OpenVPN Community Client — Windows / macOS / Linux  
  官方站点：https://openvpn.net/community-downloads/
- Outline 客户端 — Windows / Linux  
  官方站点：https://getoutline.org/

仓库结构（将被创建）
- README.md                — 本文件  
- manifest/programs.json   — 程序清单与下载源模板（请在必要时填写 direct_url）  
- download_and_assemble.sh — Unix/macOS 下载与组装脚本（交互式/非交互式）  
- download_and_assemble.ps1— Windows PowerShell 脚本  
- checksums.txt            — 用于记录并校验 SHA256（脚本会更新此文件）  
- portable/                — 便携目录模板（scripts/、programs/... 占位）  
- .gitignore               — 忽略下载后的大文件（避免意外提交）

简要使用步骤（在你本地机器上）
1. 克隆仓库到本地：
   git clone https://github.com/wb100520/-.git
   cd 梯子

2. （可选）编辑 `manifest/programs.json`，为每个程序和平台填写 `direct_url`（直接下载链接）和 `checksum_url`（如果官方提供）。如果你不填写，脚本会在运行时提示你粘贴每个文件的官方下载直链。

3. 在 Linux/macOS 上运行（推荐使用 Bash）：
   chmod +x download_and_assemble.sh
   ./download_and_assemble.sh

   在 Windows（PowerShell 7+）上运行：
   ./download_and_assemble.ps1

   脚本会：
   - 为每个 manifest 条目尝试下载（或提示你提供 direct URL）；
   - 校验 SHA256（若 manifest 中有 checksum_url 或你手动提供 hash）；
   - 将文件放入 `portable/<program>/<platform>/` 目录；
   - 生成最终 ZIP（build/<repo>-portable-<timestamp>.zip），并输出路径。

4. 检查并确认 `portable/` 目录与 ZIP 文件可以独立运行。

依赖/先决条件
- Linux/macOS：curl 或 wget，jq，unzip，sha256sum（或 shasum -a 256）  
- Windows (PowerShell)：Invoke-WebRequest（内置），Expand-Archive，Get-FileHash（用于校验）

安全注意
- 始终通过官方站点获取下载链接并校验 SHA256/GPG（如果官方提供）。  
- 不要把未经审查的第三方免费 VPN/代理客户端放入便携包。  
- 若需协助解读某个服务商的隐私策略或校验签名，我可以帮你审阅但不会帮助规避法律或封锁。

如需进一步自定义（例如将 GitHub Actions 加入自动打包并发布 Release），回复我“开启 Actions 我来配置”，我会帮你在 repo 中添加 workflow（但 Actions 需要你在 GitHub 上启用并可能授权）。