# Dart frog proxy server to post on twitter.

NOTE:

## Example

Method: POST
Route_name: /upload_media
header:

```
'Authorization': 'Bearer <supabase service role key/anon key>'
```

body:

```
{

    "supabaseUrl":"https://<project-ref-id>.supabase.co",
    "queueId":"<queue id>",
    "userId":"<user id from info table>"
}

```
