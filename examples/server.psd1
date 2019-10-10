@{
    Web = @{
        Static = @{
            Defaults = @(
                'index.html',
                'default.html'
            )
            Cache = @{
                Enable = $true
                MaxAge = 15
                Include = @(
                    '*.jpg'
                )
            }
        }
        ErrorPages = @{
            ShowExceptions = $true
            StrictContentTyping = $true
            Default = 'application/html'
            Routes = @{
                '/john' = 'application/json'
            }
        }
    }
    Server = @{
        FileMonitor = @{
            Enable = $true
            ShowFiles = $true
        }
        Logging = @{
            Masking = @{
                Patterns = @(
                    '(?<keep_before>Password=)\w+',
                    '(?<keep_before>AppleWebKit\/)\d+\.\d+(?(<keep_after)\s+\(KHTML)'
                )
                Mask = '--MASKED--'
            }
        }
    }
}