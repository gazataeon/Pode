# Overview

Authentication can either be sessionless (requiring validation on every request), or session-persistent (only requiring validation once, and then checks against a session signed-cookie).

!!! info
    To use session-persistent authentication you will also need to use Session Middleware.

To setup and use authentication in Pode you need to use the  [`New-PodeAuthType`](../../../Functions/Authentication/New-PodeAuthType) and  [`New-PodeAuthType`](../../../Functions/Authentication/New-PodeAuthType) functions, as well as the  [`New-PodeAuthType`](../../../Functions/Authentication/New-PodeAuthType) function for defining authentication Middleware.

## Functions

### New-PodeAuthType

The  [`New-PodeAuthType`](../../../Functions/Authentication/New-PodeAuthType) function allows you to create and configure Basic/Form authentication types, or you can create your own Custom authentication types. These types can then be used on the  [`New-PodeAuthType`](../../../Functions/Authentication/New-PodeAuthType) function.

An example of creating Basic/Form authentication is as follows:

```powershell
Start-PodeServer {
    $basic_auth = New-PodeAuthType -Basic
    $form_auth = New-PodeAuthType -Form
}
```

Where as the following example defines a Custom type that retrieves the user credentials from Headers:

```powershell
Start-PodeServer {
    $custom_type = New-PodeAuthType -Custom -ScriptBlock {
        param($e, $opts)

        # get client/user/pass field names to get from payload
        $clientField = (Protect-PodeValue -Value $opts.ClientField -Default 'client')
        $userField = (Protect-PodeValue -Value $opts.UsernameField -Default 'username')
        $passField = (Protect-PodeValue -Value $opts.PasswordField -Default 'password')

        # get the client/user/pass from the post data
        $client = $e.Data.$clientField
        $username = $e.Data.$userField
        $password = $e.Data.$passField

        # return the data, to be passed to the validator script
        return @($client, $username, $password)
    }
}
```

### Add-PodeAuth

The  [`Add-PodeAuth`](../../../Functions/Authentication/Add-PodeAuth) function allows you to add authentication methods to your server. You can have many methods configured, defining which one to validate against using the  [`Add-PodeAuth`](../../../Functions/Authentication/Add-PodeAuth) function.

An example of using  [`Add-PodeAuth`](../../../Functions/Authentication/Add-PodeAuth) for Basic authentication is as follows:

```powershell
Start-PodeServer {
    New-PodeAuthType -Basic | Add-PodeAuth -Name 'Login' -ScriptBlock {
        param($username, $pass)
        # logic to check user
        return @{ 'user' = $user }
    }
}
```

The `-Name` of the authentication method must be unique. The `-Type` comes from  [`New-PodeAuthType`](../../../Functions/Authentication/New-PodeAuthType), and can also be pied in.

The `-ScriptBlock` is used to validate a user, checking if they exist and the password is correct (or checking if they exist in some data store). If the ScriptBlock succeeds, then a `User` needs to be returned from the script as `@{ User = $user }`. If `$null`, or a null user is returned then the script is assumed to have failed - meaning the user will have failed authentication.

### Get-PodeAuthMiddleware

The  [`Get-PodeAuthMiddleware`](../../../Functions/Authentication/Get-PodeAuthMiddleware) function allows you to define which authentication method to validate a Request against. It returns valid Middleware, meaning you can either use it on specific Routes, or globally for all routes as Middleware. If this action fails, then a 401 response is returned.

An example of using  [`Get-PodeAuthMiddleware`](../../../Functions/Authentication/Get-PodeAuthMiddleware) against Basic authentication is as follows. The first example sets up global middleware, whereas the second example sets up custom Route Middleware:

```powershell
Start-PodeServer {
    # 1. apply as global middleware
    Get-PodeAuthMiddleware -Name 'Login' | Add-PodeMiddleware -Name 'GlobalAuthValidation'

    # 2. or, apply as custom route middleware
    Add-PodeRoute -Method Get -Path '/users' -Middleware (Get-PodeAuthMiddleware -Name 'Login') -ScriptBlock {
        # route logic
    }
}
```

On success, it will allow the Route logic to be invoked. If Session Middleware has been configured then an authenticated session is also created for future requests, using a signed session-cookie.

When the user makes another call using the same authenticated session and that cookie is present, then  [`Get-PodeAuthMiddleware`](../../../Functions/Authentication/Get-PodeAuthMiddleware) will detect the already authenticated session and skip validation. If you're using sessions and you don't want to check the session, or store the user against a session, then use the `-Sessionless` switch.

## Users

After successful validation, an `Auth` object will be created for use against the current web event. This `Auth` object will be accessible via the argument supplied to Routes and Middleware (though it will only be available in Middleware created after the Middleware from  [`Get-PodeAuthMiddleware`](../../../Functions/Authentication/Get-PodeAuthMiddleware) is invoked).

The `Auth` object will also contain:

| Name | Description |
| ---- | ----------- |
| User | Details about the authenticated user |
| IsAuthenticated | States if the request is for an authenticated user, can be `$true`, `$false` or `$null` |
| Store | States whether the authentication is for a session, and will be stored as a cookie |

The following example get the user's name from the `Auth` object:

```powershell
Add-PodeRoute -Method Get -Path '/' -Middleware (Get-PodeAuthMiddleware -Name 'Login') -ScriptBlock {
    param($e)

    Write-PodeViewResponse -Path 'index' -Data @{
        'Username' = $e.Auth.User.Name;
    }
}
```

## Inbuilt Authenticators

Overtime Pode will start to support inbuilt authentication methods - such as [Windows Active Directory](../Inbuilt/WindowsAD). More information can be found in the Inbuilt section.

For example, the below would use the inbuilt Windows AD authentication method:

```powershell
Start-PodeServer {
    New-PodeAuthType -Basic | Add-PodeAuthWindowsAd -Name 'Login'
}
```
