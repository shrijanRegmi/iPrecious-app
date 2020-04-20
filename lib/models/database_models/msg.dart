class Message {
  final msg;
  final sender;
  final receiver;
  final date;
  final seenState;
  Message({
    this.msg,
    this.sender,
    this.receiver,
    this.date,
    this.seenState,
  });
}

class Challenge {
  final challenge;
  Challenge(this.challenge);
}
