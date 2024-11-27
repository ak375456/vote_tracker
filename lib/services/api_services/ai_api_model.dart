class ChatGPTAPIModel {
  String? result;
  bool? status;
  String? serverCode;

  ChatGPTAPIModel({this.result, this.status, this.serverCode});

  ChatGPTAPIModel.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    status = json['status'];
    serverCode = json['server_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    data['status'] = this.status;
    data['server_code'] = this.serverCode;
    return data;
  }
}
