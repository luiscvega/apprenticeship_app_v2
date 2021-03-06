# Code Apprentice a.k.a Apprenticeship Application (Latest Version)
### A web app where Students and Mentors can interact in Apprenticeships

When User A creates an account, he can add Mentors from a list of available mentors. ANYONE can be mentor. User A can create a student-mentor relationship (called an 'apprenticeship'). Likewise, other users can add User A as their mentor.

If User A doesn't want to be in a list of available mentors (hence not allowing any new apprenticeships to be created), User A can turn off his "Mentor Mode". In a nutshell, if Mentor Mode is turned "ON", other people can add that user as a mentor. If Mentor Mode is turned "OFF", the user will not be in the list of available mentors, hence will not accept new apprenticeships.

## Notification System

The notification system is where Student A will send a message to Mentor B, and Mentor B will see an indicator that he has received a new message. It's similar to Facebook's Notification system, where if you have 3 new messages, it will show the total number of new messages. In the case of my application, it will show "Messages (3)". I do this by creating a new table called "Notification", where a message has_one notification. When a message is created, a callback function is called and creates a new notification for that message in the Notification table

```
after_save :notify

def notify
  notification = self.create_notification(apprenticeship: self.apprenticeship)
end
```

I count the messages using this method:

```
# In the User Model  
  
def unread_messages
  Message.joins(:notification).where(recipient_id: self.id)
end

# In the View (Note: Index page view lists each apprenticeships, so I have to scope further and indicate which apprenticeship exactly)

= link_to "Messages #{"(#{current_user.unread_messages.where(apprenticeship_id: apprenticeship.id).count})" unless current_user.unread_messages.where(apprenticeship_id: apprenticeship.id).count == 0 }", apprenticeship_url(apprenticeship)
```

I then delete the notifications when the user goes into the show page of the apprenticeship (where the messages are listed)

```
# In the Application Controller (I placed in this in the Application Controller since use this method to delete other notification collections other than messages, such as meetups and resources).

def destroy_notifications(collection)
  collection.each do |message|
    message.notification.destroy if !message.notification.nil? && message.notification.creator != current_user
  end
end

# In Apprenticeships controller, Index action

@messages = current_apprenticeship.messages.order(:created_at).page(params[:page]).per(13)
destroy_notifications(@messages)
```

## The Seed File

I play around with Blocks and Procs in the seed file since it's essentially ruby. I know I didn't have to create a proc but I wanted to experiment to play around with this tool.

```
apprenticeships = {
    "Luis Vega"       => "Fred Lee",
    "Alex Bartling"   => "Aaron Kalin",
    "Charles Jackson" => "Ray Hightower",
    "Matt Duff"       => "Jeff Cohen"
  }

  students = apprenticeships.keys
  mentors = apprenticeships.values
  everyone = students + mentors #Haha

  create_users = Proc.new do |name|
              first = name.split.first.downcase
              last = name.split.last.downcase
              User.create(:first_name => first.capitalize,
                          :last_name => last.capitalize,
                          :email => first + "@" + last + ".com",
                          :password => first,
                          :password_confirmation => first,
                          :description => "I'm #{first.capitalize} #{last.capitalize}!")
            end

  everyone.each { |name| create_users.call name }

  i = 0
  while (i \< apprenticeships.count)
    apprenticeship = Apprenticeship.new
    apprenticeship.student = User.find_by_first_name(students[i].split.first) && User.find_by_last_name(students[i].split.last)
    apprenticeship.mentor = User.find_by_first_name(mentors[i].split.first) && User.find_by_last_name(mentors[i].split.last)
    apprenticeship.save
    i+=1
  end
```

## Polymorphism

Since I have a table for Messages, Meetups and Resources (and probably more tables later on), I decided to implement Polymorphism for the Notifications Table, since they all will have a "has_one :notification" association. Hence, the notification model is as follows: 

```
class Notification < ActiveRecord::Base
  belongs_to :apprenticeship
  
  belongs_to :notifiable, polymorphic: true
  
  def creator
    self.notifiable.user
  end
end

#Schema

Notification(id: integer, apprenticeship_id: ... notifiable_id: integer, notifiable_type: string) 
```


## Other interesting code:

Scoping Available Mentors from Users

```
scope :available_mentors, lambda { |current_user| 
    where("mentor = ?", true).
    where("id <> ?", current_user.id).
    where(["id NOT IN (?)", current_user.apprenticeships.map {|u| u.student.id }]).
    where(["id NOT IN (?)", current_user.apprenticeships.map {|u| u.mentor.id }])
  }
```

Find the Current User's Apprenticeship

```
def current_apprenticeship # Key method, show the current apprenticeship of the current user.
   Apprenticeship.find_by_id(params[:apprenticeship_id]) || Apprenticeship.find_by_id(params[:id])
 end
```

Find the other user the Current Apprenticeship

```
def other_user
  current_user == current_apprenticeship.student ? current_apprenticeship.mentor : current_apprenticeship.student
end
```