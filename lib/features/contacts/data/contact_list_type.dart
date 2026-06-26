enum ContactListType {
  contacts('accepted'),
  incoming('pending'),
  sent('sent');

  const ContactListType(this.apiStatus);

  final String apiStatus;
}
