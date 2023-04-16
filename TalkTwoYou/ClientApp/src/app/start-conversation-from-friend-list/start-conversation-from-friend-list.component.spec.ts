import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AngularFireModule } from '@angular/fire/compat';
import { environment } from 'src/environments/environment';
import { StartConversationFromFriendListComponent } from './start-conversation-from-friend-list.component';

describe('StartConversationFromFriendListComponent', () => {
  let component: StartConversationFromFriendListComponent;
  let fixture: ComponentFixture<StartConversationFromFriendListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AngularFireModule.initializeApp(environment.firebase)],
      declarations: [ StartConversationFromFriendListComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(StartConversationFromFriendListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
