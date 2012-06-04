# buffered_job

Buffering jobs for a period to do specific method when two or more similer jobs in 
a buffer.

## Scenario

If you implement email notification. To avoid sending too many mail to a 
receipient, you can merge multiple notificaiton in one mail.

That mean, if a user get comment notification for his blog article.

```
 c = @article.comments.create(:user => @jon, :text => "i love this article!")
 # if this invoke , when @user = @article.user
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

```Gemfile
gem 'buffered_job',:git => 'git://github.com/sawamur/buffered_job.git'
```


## Peparation

```
$ (bundle exec) rails generate buffered_job
$ (bundle exec) rake db:migrate
```


## Dependancies

This module depends on delayed_job.Set up delayed_job and run delayed_job worker


## Usage

```
@user.buffer.post_to_twitter(@article1)
@user.buffer.post_to_twitter(@aritcle2)
``` 
 
invoke merge_* medtho in User mode

```
def merge_post_to_twitter(@articles)
 ..
end
```

 

## Copyright

Copyright (c) 2012 Masaki Sawamura. See LICENSE.txt for
further details.

