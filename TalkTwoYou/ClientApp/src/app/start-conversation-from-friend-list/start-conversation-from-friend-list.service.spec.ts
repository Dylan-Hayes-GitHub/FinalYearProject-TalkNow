import { TestBed } from '@angular/core/testing';

import { StartConversationFromFriendListService } from './start-conversation-from-friend-list.service';
import { AngularFireModule } from '@angular/fire/compat';
import { environment } from 'src/environments/environment';
import { HttpClientModule } from '@angular/common/http';
describe('StartConversationFromFriendListService', () => {
  let service: StartConversationFromFriendListService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [AngularFireModule.initializeApp(environment.firebase)],
      providers: [StartConversationFromFriendListService]
    });
    service = TestBed.inject(StartConversationFromFriendListService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
