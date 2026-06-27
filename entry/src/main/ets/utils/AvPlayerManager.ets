import { media } from '@kit.MediaKit'
import { GlobalMusic } from '../models/globalMusic'
import { SongItemType } from '../models/music'
import { AppStorageV2 } from '@kit.ArkUI'
import { sessionManager } from './AvSessionManager'

class AvPlayerManager {
  // 播放器
  player: media.AVPlayer | null = null
  // 共享播放数据
  currentSong: GlobalMusic = AppStorageV2.connect(GlobalMusic, 'SONG_KEY', () => new GlobalMusic())!

  // 定义方法 创建播放器 + 监听播放器的状态
  async init() {
    if (!this.player) {
      this.player = await media.createAVPlayer()
    }

    this.player.on('stateChange', (state) => {
      if (state === 'initialized') {
        this.player?.prepare()
      } else if (state === 'prepared') {
        this.player?.play()
        this.currentSong.isPlay = true
      } else if (state === 'completed') {
        this.nextPlay(true) // 自动下一首
      }else if (state === 'released'){
        this.currentSong.reset()
      }
    })
    // 时间变化
    this.player.on('durationUpdate', (duration) => {
      this.currentSong.duration = duration
      sessionManager.setAVMetadata(this.currentSong.playList[this.currentSong.playIndex])
    })
    this.player.on('timeUpdate', (time) => {
      this.currentSong.time = time
      sessionManager.setAVPlayBackState()
    })
  }

  // 播放歌曲 → 设置播放资源
  // singPlay (song: SongItemType) {
  //   this.player!.url = song.url
  //   this.currentSong.img= song.img
  // }
  singPlay(song: SongItemType) {
    //申请长时任务
    sessionManager.startBackgroundTask()
    sessionManager.setAVPlayBackState()
    // 是否在列表 → some 检查数组里面的数据是否满足条件 → 只要有一个满足 some 返回 true
    const inList = this.currentSong.playList.some(item => item.id === song.id)
    if (inList) {
      // 在列表里面 → 是否是正在播放的 → currentSong url === song.url
      if (this.currentSong.url === song.url) {
        this.player?.play()
        this.currentSong.isPlay = true
      } else {
        // 设置新的索引 → 切歌
        this.currentSong.playIndex = this.currentSong.playList.findIndex(item => item.id === song.id)
        // 切歌
        this.changeSong()
      }
    } else {
      // 不在列表里面 → 添加到列表 + 切换歌曲
      this.currentSong.playList.unshift(song)
      this.currentSong.playIndex = 0
      // 切换歌曲
      this.changeSong()
    }
  }

  // 切换歌曲 → 重新播放器
  async changeSong() {
    await this.player?.reset()
    this.currentSong.duration = 0
    this.currentSong.time = 0
    this.currentSong.img = this.currentSong.playList[this.currentSong.playIndex].img
    this.currentSong.name = this.currentSong.playList[this.currentSong.playIndex].name
    this.currentSong.author = this.currentSong.playList[this.currentSong.playIndex].author
    this.currentSong.url = this.currentSong.playList[this.currentSong.playIndex].url
    this.player!.url = this.currentSong.url
  }

  // 跳转进度 seek
  seekPlay(value: number) {
    this.player?.seek(value)
  }

  // 暂停
  paused() {
    this.player?.pause()
    this.currentSong.isPlay = false
    sessionManager.setAVPlayBackState()
  }

  // 上一首
  prevPlay () {
    if (this.currentSong.playMode === 'random') {
      // 随机
      this.currentSong.playIndex = Math.floor(Math.random() * this.currentSong.playList.length)
    } else {
      this.currentSong.playIndex--
      if (this.currentSong.playIndex < 0) {
        // 去最后一首
        this.currentSong.playIndex = this.currentSong.playList.length - 1
      }
    }
    this.singPlay(this.currentSong.playList[this.currentSong.playIndex])
  }

  // 下一首: 根据播放模式计算索引 播放 → if
  // 真的重复播放 → 播放模式为 repeat 并且 播放器自动下一首 → completed → 传入一个数据表示是自动的
  // 随机 → 计算随机索引
  // 列表 → ++
  nextPlay(autoNextPlay?: boolean) {
    if (this.currentSong.playMode === 'repeat' && autoNextPlay) {
      // 真的重复 → 索引不变
      this.currentSong.playIndex = this.currentSong.playIndex
    } else if (this.currentSong.playMode === 'random') {
      // 随机
      // Math.random() [0-1) 随机小数
      this.currentSong.playIndex = Math.floor(Math.random() * this.currentSong.playList.length)
    } else {
      // 列表
      this.currentSong.playIndex++
      if (this.currentSong.playIndex >= this.currentSong.playList.length) {
        // 去第一首
        this.currentSong.playIndex = 0
      }
    }
    this.singPlay(this.currentSong.playList[this.currentSong.playIndex])
  }

  // 列表移除歌曲
  removeSong (index: number) {
    if (index === this.currentSong.playIndex) {
      // 删除的是正在播放的
      if (this.currentSong.playList.length > 1) {
        // 列表里面有多首歌
        this.currentSong.playList.splice(index, 1)
        // 播放索引如果大于等于了长度，回第一首播放
        if (this.currentSong.playIndex >= this.currentSong.playList.length) {
          this.currentSong.playIndex = 0
        }
        this.singPlay(this.currentSong.playList[this.currentSong.playIndex])
      } else {
        // 列表里面只有一首歌
        this.player?.reset()
        this.currentSong.reset()
      }
    } else {
      // 删除的不是正在播放的歌曲
      if (index < this.currentSong.playIndex) {
        // 要删除的在播放的前面
        this.currentSong.playIndex--
      }
      // 移除 → 删除的索引，删除个数
      this.currentSong.playList.splice(index, 1)
    }
  }
  // 释放播放器 和 播放数据
  async release () {
    await this.player?.release()
  }
}


export const playerManager: AvPlayerManager = new AvPlayerManager()