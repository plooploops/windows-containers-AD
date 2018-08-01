[Reflection.Assembly]::LoadWithPartialName("System.Messaging")

cls

#$queueName = '.\Private$\NealTest'
$queueName = $Env:QUEUE_NAME
$queue = new-object System.Messaging.MessageQueue $queueName
$utf8  = new-object System.Text.UTF8Encoding

$msgs = $queue.GetAllMessages()
 
write-host "Number of messages=$($msgs.Length)" 

foreach ($msg in $msgs)
  {
      write-host $msg_.Id
      write-host $utf8.GetString($msg.BodyStream.ToArray())
  }