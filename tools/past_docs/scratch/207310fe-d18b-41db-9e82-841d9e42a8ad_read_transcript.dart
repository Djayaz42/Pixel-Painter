import 'dart:convert';
import 'dart:io';

void main() {
  final file = File(r'C:\Users\Abdullah\.gemini\antigravity\brain\207310fe-d18b-41db-9e82-841d9e42a8ad\.system_generated\logs\transcript.jsonl');
  if (!file.existsSync()) {
    print('File does not exist');
    return;
  }
  
  final lines = file.readAsLinesSync();
  int start = -1;
  int end = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('"step_index":2881')) {
      start = i;
    }
    if (lines[i].contains('"step_index":2935')) {
      end = i;
      break;
    }
  }
  
  if (start == -1 || end == -1) {
    print('Start ($start) or End ($end) not found');
    // Let's print the last 20 lines anyway
    print('Printing last 10 lines:');
    final startIdx = lines.length > 10 ? lines.length - 10 : 0;
    for (int i = startIdx; i < lines.length; i++) {
      final decoded = jsonDecode(lines[i]);
      print('Step: ${decoded["step_index"]}, Type: ${decoded["type"]}, Content: ${decoded["content"]}');
    }
    return;
  }
  
  for (int i = start; i <= end; i++) {
    final decoded = jsonDecode(lines[i]);
    print('--------------------------------------------------');
    print('Step: ${decoded["step_index"]}, Source: ${decoded["source"]}, Type: ${decoded["type"]}');
    print('Content: ${decoded["content"]}');
  }
}
