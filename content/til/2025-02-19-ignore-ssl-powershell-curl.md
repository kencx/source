---
title: "Ignoring SSL cert verification in Powershell"
date: 2025-02-19
lastmod: 2025-02-19
draft: false
toc: false
tags:
- powershell
- curl
---

In Powershell 5.1, there is no flag to easily ignore SSL/TLS verification in `curl` or `Invoke-WebRequest`. The following is a workaround:

```powershell
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
Invoke-WebRequest -Uri "https://api.example.com"
```

In Powershell >7, we can use the `-SkipCertificateCheck` flag.

## References
- [Powershell - Invoke-WebRequest](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7.5)
