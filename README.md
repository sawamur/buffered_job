# buffered_job


[![Build Status](https://secure.travis-ci.org/sawamur/buffered_job.png)](http://travis-ci.org/sawamur/buffered_job)


Buffering jobs for a certain period and invoke specific method if two or more similer jobs in 
a buffer.

## Scenario

Supposing that you are running sort of social media that has user articles which accept comments on each. 
You'll probably want to have email notification for incomming comments on a article. 
If you implement straightforward, the auther of popular article would receive tons of email for an article.
That must be bothering. To avoid sending too many mails to a receipient, you can merge multiple 
notificaiton messages into an array and process it with another specific method.

That mean, if a user gets a comment notification for her blog article as follows:

```
 @article = Article.create(:user => @user,:text => "my blog article here")
 c = @article.comments.create(:user => @jon, :text => "i love this article!")
 @user.notify(c)
```

Then. With this module,you can buffer `notify` method 

```
 c1 = @article.comments.create(:user => @jon, :text => "i love this article!")
 c2 = @article.comments.create(:user => @ken, :text => "i hate this article!")

 @user.buffer.notify(c1)
 @user.buffer.notify(c2)
 # these two methods would be translated to
 @user.merge_notify([c1,c2])
 # then you can build other notification email with arryed comment objects
```


## Install


```
$ gem install buffered_job
```

or in Gemfile

```
gem 'buffered_job'
```

then, `bundle install`



## Peparation

```
$ (bundle exec) rails generate buffered_job
$ (bundle exec) rake db:migrate
```


## Dependancies

This module depends on delayed_job.Set up delayed_job and intended to use in rails
applications. You have to run delayed_job worker.


## Usage

Every active_record object has `buffer` method. You can put it  between receiver and method and bufferes method
along with argument object.


```
@user.buffer.post_to_twitter(@article1)
@user.buffer.post_to_twitter(@aritcle2)
``` 

When flushing buffer,if two methods above is detected, that would  
invoke merge_{:original_method} method insted of original method on 
that User model,so in this case, you must define `merge_post_to_twitter` in User model.

```
def merge_post_to_twitter(articles)
 ..
end
```

## Current Limitation

Only one argument object can be passed to buffered method. 


## Configuration 

default buffering time is tree munites. To modify,

```
BufferedJob.delay_time = 30.seconds
```


## Copyright

Copyright (c) 2012 Masaki Sawamura. 
See LICENSE.txt for further details.

