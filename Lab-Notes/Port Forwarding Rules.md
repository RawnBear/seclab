| Interface      | Protocol | IP                             | Port(s) | Description       |
| -------------- | -------- | ------------------------------ | ------- | ----------------- |
| Infrastructure | TCP      | *                              | *       | Anti-lockout rule |
| WAN            | TCP      | BearLab_Jumpbox (192.168.14.3) | 3389    | Jumpbox RDP       |
| WAN            | TCP      | BearLab_Jumpbox (192.168.14.3) | 2222    | Jumpbox SSH       |
| Infrastructure | TCP      | proxmox_node (192.168.13.37)   | 443     | Proxmox           |
