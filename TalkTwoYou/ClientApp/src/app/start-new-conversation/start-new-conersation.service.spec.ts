import { TestBed } from '@angular/core/testing';
import { HttpClientModule } from '@angular/common/http';
import { StartNewConversationService } from './start-new-conversation.service';
import { AngularFireModule } from '@angular/fire/compat';
import { environment } from 'src/environments/environment';
describe('StartNewConersationService', () => {
  let service: StartNewConversationService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientModule, AngularFireModule.initializeApp(environment.firebase)]
    });
    service = TestBed.inject(StartNewConversationService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
