extends Node
# Dollar Horde - SoundManager (autoload)
# Procedural audio generation — no external files needed

var _players: Array[AudioStreamPlayer] = []
var _max_players := 16
var _music_player: AudioStreamPlayer
var _music_playing := false

# Pre-generated audio streams
var _sfx: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Create audio buses
	_ensure_bus("SFX", 0.0)
	_ensure_bus("Music", -6.0)

	# Pool audio stream players for SFX
	for i in _max_players:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_players.append(p)

	# Music player
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	# Generate all SFX
	_generate_all_sfx()

func _ensure_bus(bus_name: String, volume_db: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		idx = AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, bus_name)
	AudioServer.set_bus_volume_db(idx, volume_db)
	AudioServer.set_bus_send(idx, "Master")

func _get_free_player() -> AudioStreamPlayer:
	for p in _players:
		if not p.playing:
			return p
	# All busy — steal the oldest
	return _players[0]

func play_sfx(sound_name: String, pitch_variation: float = 0.0, volume_db: float = 0.0) -> void:
	if not _sfx.has(sound_name):
		push_warning("SoundManager: SFX '%s' not found" % sound_name)
		return
	var player := _get_free_player()
	player.stream = _sfx[sound_name]
	player.volume_db = volume_db
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()

func play_music() -> void:
	if _music_playing:
		return
	_music_player.stream = _generate_music_loop()
	_music_player.volume_db = -12.0
	_music_player.play()
	_music_playing = true

func stop_music() -> void:
	_music_player.stop()
	_music_playing = false

# ─── Procedural SFX Generation ───

func _generate_all_sfx() -> void:
	_sfx["shoot"] = _gen_tone(0.08, 800.0, 0.15, "square", 0.3)
	_sfx["shoot_crit"] = _gen_tone(0.1, 1200.0, 0.2, "square", 0.2)
	_sfx["hit"] = _gen_noise(0.06, 0.3, 8000.0)
	_sfx["enemy_death"] = _gen_tone(0.15, 200.0, 0.4, "sawtooth", 0.5)
	_sfx["player_hurt"] = _gen_tone(0.2, 150.0, 0.6, "sawtooth", 0.8)
	_sfx["pickup"] = _gen_tone(0.1, 600.0, 0.1, "sine", 0.0)
	_sfx["level_up"] = _gen_chord(0.4, [523.25, 659.25, 783.99], 0.3)
	_sfx["game_over"] = _gen_tone(0.6, 100.0, 0.8, "sawtooth", 1.0)
	_sfx["wave_start"] = _gen_tone(0.3, 440.0, 0.2, "triangle", 0.0)
	_sfx["button_click"] = _gen_tone(0.05, 1000.0, 0.1, "square", 0.0)

func _gen_tone(duration: float, freq: float, volume: float, waveform: String, freq_end: float = -1.0) -> AudioStreamWAV:
	if freq_end < 0:
		freq_end = freq
	var sample_rate := 44100
	var num_samples := int(duration * sample_rate)
	var data := PackedByteArray()
	data.resize(num_samples * 2)  # 16-bit mono

	for i in num_samples:
		var t := float(i) / sample_rate
		var progress := float(i) / num_samples
		var current_freq := freq + (freq_end - freq) * progress
		var phase := fmod(t * current_freq, 1.0)
		var amp := volume * (1.0 - progress * 0.5)  # slight decay

		var sample: float
		match waveform:
			"sine":
				sample = sin(phase * TAU) * amp
			"square":
				sample = 1.0 if phase < 0.5 else -1.0
				sample *= amp
			"sawtooth":
				sample = (phase * 2.0 - 1.0) * amp
			"triangle":
				sample = (abs(phase * 2.0 - 1.0) * 2.0 - 1.0) * amp
			_:
				sample = sin(phase * TAU) * amp

		# Apply envelope (quick attack, short decay)
		var envelope := 1.0
		if t < 0.01:
			envelope = t / 0.01
		elif t > duration * 0.6:
			envelope = 1.0 - (t - duration * 0.6) / (duration * 0.4)
		sample *= envelope

		var raw := clampi(int(sample * 32767), -32768, 32767)
		data[i * 2] = raw & 0xFF
		data[i * 2 + 1] = (raw >> 8) & 0xFF

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _gen_noise(duration: float, volume: float, filter_freq: float = 10000.0) -> AudioStreamWAV:
	var sample_rate := 44100
	var num_samples := int(duration * sample_rate)
	var data := PackedByteArray()
	data.resize(num_samples * 2)

	var last_sample := 0.0
	var alpha := filter_freq / (filter_freq + sample_rate)

	for i in num_samples:
		var t := float(i) / sample_rate
		var raw_noise := randf_range(-1.0, 1.0)
		last_sample = last_sample + alpha * (raw_noise - last_sample)

		var progress := float(i) / num_samples
		var envelope := 1.0 - progress  # linear decay
		var sample := last_sample * volume * envelope

		var raw := clampi(int(sample * 32767), -32768, 32767)
		data[i * 2] = raw & 0xFF
		data[i * 2 + 1] = (raw >> 8) & 0xFF

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _gen_chord(duration: float, frequencies: Array, volume: float) -> AudioStreamWAV:
	var sample_rate := 44100
	var num_samples := int(duration * sample_rate)
	var data := PackedByteArray()
	data.resize(num_samples * 2)

	for i in num_samples:
		var t := float(i) / sample_rate
		var sample := 0.0
		for freq in frequencies:
			sample += sin(t * freq * TAU)
		sample /= float(frequencies.size())

		# Envelope: quick attack, hold, decay
		var envelope := 1.0
		if t < 0.02:
			envelope = t / 0.02
		elif t > duration * 0.5:
			envelope = 1.0 - (t - duration * 0.5) / (duration * 0.5)
		sample *= volume * envelope

		var raw := clampi(int(sample * 32767), -32768, 32767)
		data[i * 2] = raw & 0xFF
		data[i * 2 + 1] = (raw >> 8) & 0xFF

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _generate_music_loop() -> AudioStreamWAV:
	# Simple looping ambient track — low drone with rhythmic pulse
	var sample_rate := 44100
	var loop_duration := 8.0  # 8-second loop
	var num_samples := int(loop_duration * sample_rate)
	var data := PackedByteArray()
	data.resize(num_samples * 2)

	for i in num_samples:
		var t := float(i) / sample_rate

		# Bass drone (55 Hz)
		var bass := sin(t * 55.0 * TAU) * 0.15
		# Sub octave
		bass += sin(t * 27.5 * TAU) * 0.1

		# Rhythmic pulse (120 BPM = 2 Hz)
		var pulse_phase := fmod(t * 2.0, 1.0)
		var pulse := 1.0 if pulse_phase < 0.1 else 0.0
		bass += pulse * 0.08 * sin(t * 110.0 * TAU)

		# Pad chord (minor: A C E)
		var pad := 0.0
		pad += sin(t * 220.0 * TAU) * 0.04
		pad += sin(t * 261.63 * TAU) * 0.03
		pad += sin(t * 329.63 * TAU) * 0.03
		# Slow LFO on pad
		pad *= 0.7 + 0.3 * sin(t * 0.25 * TAU)

		# Hi-hat tick
		var hat_phase := fmod(t * 4.0, 1.0)  # 4 Hz
		var hat := 0.0
		if hat_phase < 0.05:
			hat = randf_range(-1.0, 1.0) * 0.03 * (1.0 - hat_phase / 0.05)

		var sample := bass + pad + hat
		var raw := clampi(int(sample * 32767), -32768, 32767)
		data[i * 2] = raw & 0xFF
		data[i * 2 + 1] = (raw >> 8) & 0xFF

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = num_samples
	stream.data = data
	return stream
