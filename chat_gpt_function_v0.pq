let
    Output = (prompt as text) as text =>
    let
        url = "https://api.openai.com/v1/chat/completions",
        apiKey = "**APIKEY**",
        headers = [
            #"Content-Type" = "application/json",
            #"Authorization" = "Bearer " & apiKey
        ],
        body = Json.FromValue([model = "gpt-3.5-turbo", messages = {[role="user", content = prompt]}]),
        response = Web.Contents(url, [Headers=headers, Content=body]),
        content = Json.Document(response)[choices]{0}[message][content]
    in
        content
in
    Output
