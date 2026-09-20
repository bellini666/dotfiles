---
name: transcribe
description: This skill should be used when the user asks to transcribe an audio or video file, "what does this audio say", "transcribe this voice message", "get the text from this recording", asks for subtitles or an SRT/VTT file, or attaches an audio file and wants its contents.
---

# Transcribe Audio

Local transcription with Whisper on Apple Silicon. No upload, no API key.

## Command

```sh
uvx --from mlx-whisper mlx_whisper \
    --model mlx-community/whisper-large-v3-turbo \
    --output-dir "$SCRATCHPAD" \
    --output-format txt \
    <audio-file>
```

Then read the produced `<basename>.txt` and give the user the transcript inline.

- `--output-dir` defaults to the current directory, so always point it at the scratchpad. Never leave transcript files in the repo.
- The model is already in `~/.cache/huggingface/hub`. Use a different one only if asked.
- Omit `--language` for auto-detect. Pass it (`--language pt`) when the user names the language or when auto-detect returns something implausible.
- Any format ffmpeg reads works: ogg, m4a, mp3, wav, opus, mp4, mkv.
- Multiple files in one invocation: pass them all as positional args.

## Variations

- Subtitles: `--output-format srt` (or `vtt`).
- Word-level timing: `--word-timestamps True`, needed by `--highlight-words` and `--max-line-width`.
- Translate to English instead of transcribing in-language: `--task translate`.
- Names, jargon, or spellings the model keeps getting wrong: `--initial-prompt "Bellini, strawberry-graphql, pytest"`.

## Failure Modes

`RuntimeError: [metal::Device] Unable to build metal library from source` with
`monolithic_metal.pcm: Operation not permitted` means the safehouse profile is
missing its `(allow file-issue-extension ...)` grant for `/var/folders`. Fix
`~/.dotfiles/safehouse/extra.sb` and start a new shell. Do not fall back to a
CPU backend to work around it.

A transcript of pure repeated phrases usually means silence or music, not speech.
Check the audio length before rerunning with different settings.
