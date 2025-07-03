#include <iostream>
#include <algorithm>
#include <deque>

using namespace std;
//
int n, k, maxFloor;
int dx[4] = {0, 0, -1, 1};
int dy[4] = {1, -1, 0, 0};
int dir[12];
int color[14][14]; // 0 - White / 1 - Red / 2 - Blue
pair<int, int> pos[12];
deque<int> board[14][14];

void    chgDir(int i) {
    if (dir[i] == 0) dir[i] = 1;
    else if (dir[i] == 1) dir[i] = 0;
    else if (dir[i] == 2) dir[i] = 3;
    else dir[i] = 2;
}

void    moveWhite(int cx, int cy, int nx, int ny) {
    // cout << "moveWhite - start (" << cx << ", " << cy << ")\n";
    while (board[cx][cy].size()) {
        board[nx][ny].push_back(board[cx][cy].front());
        pos[board[cx][cy].front()] = {nx, ny};
        // cout << board[cx][cy].front() << "move to (" << nx << ", " << ny << '\n';
        board[cx][cy].pop_front();
    }
    maxFloor = max(maxFloor, (int)board[nx][ny].size());
}

void    moveRed(int cx, int cy, int nx, int ny) {
    reverse(board[cx][cy].begin(), board[cx][cy].end());
    moveWhite(cx, cy, nx, ny);
}

void    moveBlue(int cx, int cy, int i) {
    chgDir(i);
    int nx = cx + dx[dir[i]];
    int ny = cy + dy[dir[i]];
    if (nx < 1 || n < nx || ny < 1 || n < ny || color[nx][ny] == 2) return ;
    else if (color[nx][ny] == 1) moveRed(cx, cy, nx, ny);
    else moveWhite(cx, cy, nx, ny);
}

int getAns() {
    int turn = 0;
    while (maxFloor < 4 && turn <= 1000) {
        for (int i = 1; i <= k; ++i) {
            int cx = pos[i].first;
            int cy = pos[i].second;
            if (board[cx][cy].front() != i) continue ;
            int nx = cx + dx[dir[i]];
            int ny = cy + dy[dir[i]];
            if (nx < 1 || n < nx || ny < 1 || n < ny || color[nx][ny] == 2) moveBlue(cx, cy, i);
            else if (color[nx][ny] == 1) moveRed(cx, cy, nx, ny);
            else moveWhite(cx, cy, nx, ny);
        }
        ++turn;
    }
    if (turn > 1000) return -1;
    return turn;
}

int main() {
    ios::sync_with_stdio(false);
    std::cin.tie(nullptr);

    cin >> n >> k;
    for (int i = 1; i <= n; ++i) {
        for (int j = 1; j <= n; ++j)
            cin >> color[i][j];
    }
    int x, y, direction;
    for (int i = 1; i <= k; ++i) {
        cin >> x >> y >> direction;
        board[x][y].push_back(i);
        dir[i] = direction - 1;
        pos[i] = {x, y};
    }
    cout << getAns() << '\n';
}