# Personal blog with [hexo][]

## Use gulp task management system
  * work flow: generate/compact/deploy
  * sensitive configurationn can be got from environment variables
    | Environment variables | Comments |
    | --------------------: | --------------------------------------- |
    | HEXO_GITHUB_EMAIL     | user email for commiting the site files |
    | HEXO_GITHUB_TOKEN     | token value to authenticate with the repo |
    | NEXT_GOOGLE_SITECODE  | google site verification |
    | NEXT_BAIDU_SITECODE   | baidu site verification |

## Build Docker image for last well working snapshot
```bash
$ docker run -i -t --rm -v $PWD:/working --env-file ../.env wangkexiong/hexo:v20201227
$ # Copy back the generated public folder from running container
$ docker run -i -t --rm -v $PWD:/working --env-file ../.env wangkexiong/hexo:v20201227 -c
```


  [hexo]: http://hexo.io