/// Copyright (c) 2022 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

@testable import DogPatch
import Foundation

// 1. DogPatchService를 채택한 MockDogPatchService 추가
class MockDogPatchService: DogPatchService {
      
  // 2. baseURL, getDogsCallCount, getDogsCompletion, getDogsDataTask 프로퍼티 추가
  var baseURL = URL(string: "https://example.com/api/")!
  var getDogsCallCount = 0
  var getDogsCompletion: (([Dog]?, Error?) -> Void)!
  lazy var getDogsDataTask = MockURLSessionTask(
    completionHandler: { _, _, _ in },
    url: URL(string: "dogs", relativeTo: baseURL)!,
    queue: nil)
      
  // 3. DogPatchService에 필요한 getDogs(completion:)를 구현
  //      ㄴ 호출시 getDogsCallCount +=1  / getDogsCompletion 설정 / getDogsDataTask를 반환
  func getDogs(completion: @escaping ([Dog]?, Error?) -> Void) -> URLSessionTaskProtocol {
      getDogsCallCount += 1
      getDogsCompletion = completion
      return getDogsDataTask
  }
}
// 오예쓰!!!! DogPatchClient 작동 방식을 반영하고, 네트워크 연결이 필요없고, 지연이 없고, 응답이 완전히 제어된 완벽한 mock을 만들었어!
