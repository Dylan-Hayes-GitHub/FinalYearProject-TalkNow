import { TestBed } from '@angular/core/testing';
import { HttpClientModule } from '@angular/common/http';
import { PastChatRoomServiceService } from './past-chat-room-service.service';

describe('PastChatRoomServiceService', () => {
  let service: PastChatRoomServiceService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientModule]
    });
    service = TestBed.inject(PastChatRoomServiceService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
