import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParcelChatPage extends StatefulWidget {
  final String parcelId;
  final Map<String, dynamic> parcelData;

  const ParcelChatPage({
    super.key,
    required this.parcelId,
    required this.parcelData,
  });

  @override
  State<ParcelChatPage> createState() => _ParcelChatPageState();
}

class _ParcelChatPageState extends State<ParcelChatPage> {
  final _msgCtrl      = TextEditingController();
  final _scrollCtrl   = ScrollController();
  bool  _isSending    = false;

  CollectionReference get _messages => FirebaseFirestore.instance
      .collection('parcel_chats')
      .doc(widget.parcelId)
      .collection('messages');

  DocumentReference get _parcelDoc =>
      FirebaseFirestore.instance.collection('parcel_chats').doc(widget.parcelId);

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    _msgCtrl.clear();

    await _messages.add({
      'text':       text,
      'senderId':   'user',
      'senderName': widget.parcelData['sender'] ?? 'User',
      'timestamp':  FieldValue.serverTimestamp(),
    });

    setState(() => _isSending = false);

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildParcelStatusBanner(),
          _buildParcelInfoCard(),
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parcel Support',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            'ID: ${widget.parcelId.substring(0, 8).toUpperCase()}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            backgroundColor: Colors.indigo.shade50,
            child: const Icon(Icons.support_agent, color: Colors.indigo, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildParcelStatusBanner() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _parcelDoc.snapshots(),
      builder: (context, snap) {
        final status = snap.data?.get('status') as String? ?? 'Booked';
        final steps  = ['Booked', 'Picked Up', 'In Transit', 'Delivered'];
        final idx    = steps.indexOf(status);

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: List.generate(steps.length, (i) {
              final done    = i <= idx;
              final isLast  = i == steps.length - 1;
              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: done ? Colors.indigo : Colors.grey.shade200,
                          child: done
                              ? const Icon(Icons.check, color: Colors.white, size: 13)
                              : Text('${i + 1}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[i],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: done ? FontWeight.bold : FontWeight.normal,
                            color: done ? Colors.indigo : Colors.grey.shade400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          color: i < idx ? Colors.indigo : Colors.grey.shade200,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildParcelInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, color: Colors.indigo, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.parcelData['sender']} → ${widget.parcelData['receiver']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.parcelData['pickup']} → ${widget.parcelData['delivery']}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.parcelData['price'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 14),
              ),
              Text(
                widget.parcelData['packageType'] ?? '',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _messages.orderBy('timestamp', descending: false).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'No messages yet',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ask us anything about your parcel',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
          }
        });

        return ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final msg      = docs[i].data() as Map<String, dynamic>;
            final isMe     = msg['senderId'] == 'user';
            final text     = msg['text'] as String? ?? '';
            final name     = msg['senderName'] as String? ?? '';
            final ts       = msg['timestamp'] as Timestamp?;
            final timeStr  = ts != null
                ? DateFormat('hh:mm a').format(ts.toDate())
                : '';

            return _buildBubble(
              text: text,
              name: name,
              time: timeStr,
              isMe: isMe,
            );
          },
        );
      },
    );
  }

  Widget _buildBubble({
    required String text,
    required String name,
    required String time,
    required bool isMe,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.support_agent, size: 16, color: Colors.indigo),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      'Support',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.indigo : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(16),
                      topRight:    const Radius.circular(16),
                      bottomLeft:  Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    time,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.indigo.shade100,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _msgCtrl,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask about your parcel...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                ),
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
