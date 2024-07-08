let
    Output = ( description as any, optional prompt as text ) as text =>
    let
        newPrompt = if prompt = null then "Please simplify this description in a brief, succinct way. Any references to 'Learn more' and 'more information' available should be ignored. If the description contains the word '(preview)' then prefix the text with the word '(preview)' "  else prompt,
        url = "https://api.openai.com/v1/chat/completions",
        apiKey = "**APIKEY**",
        headers = [
            #"Content-Type" = "application/json",
            #"Authorization" = "Bearer " & apiKey
        ],
        body = Json.FromValue([model = "gpt-4-turbo", messages = {[role="user", content = newPrompt & ": " & description]}]),
        response = Web.Contents(url, [Headers=headers, Content=body]),
        content = Json.Document(response)[choices]{0}[message][content]
    in
        content
in
    Output
