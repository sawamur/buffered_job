# buffered_job

Buffering jobs for a certain period and invoke specific method if two or more similer jobs in 
a buffer.

## Scenario

For example.If you implement email notification for incomming comments on a article.
To avoid sending too many mail to a receipient, you can merge multiple notificaiton
messages into one mail.

That mean, if a user get comment notification for her blog article.

```
 @article = Article.create(:user => @user,:text => "my blog article here")
 c = @article.comments.create(:user => @jon, :text => "i love this article!")
 # if this invoke 
 @user.notify(c)
 # send to email
```

with this module

```
 c1 = @article.comments.create(:user => @jon, :text => "i love this article!")
 c2 = @article.comments.create(:user => @ken, :text => "i hate this article!")
 # if this invoke
 @user.buffer.notify(c1)
 @user.buffer.notify(c2)
 # these two methods would be translated to
 @user.merge_notify([c1,c2])
 # then you can build other notification email with arryed comment objects
```


## Install

in Gemfile

```
gem 'buffered_job',:git => 'git://github.com/sawamur/buffered_job.git'
```



## Peparation

```
$ (bundle exec) rails generate buffered_job
$ (bundle exec) rake db:migrate
```


## Dependancies

This module depends on delayed_job.Set up delayed_job and intended to use in rails
applications. You have to run delayed_job worker.


## Usage

```
@user.buffer.post_to_twitter(@article1)
@user.buffer.post_to_twitter(@aritcle2)
``` 
 
invoke merge_* medtho in User mode,so you should define

```
def merge_post_to_twitter(@articles)
 ..
end
```


## Configuration 

default buffering time is tree munites. To modify,

```
BufferedJob.delay_time = 30.seconds
```


## Copyright

Copyright (c) 2012 Masaki Sawamura. See LICENSE.txt for
further details.

